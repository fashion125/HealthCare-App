//
//  WebQuery.m
//  Cronometer
//
//  Created by Boris Esanu on 12/07/2011.
//  Copyright 2011 cronometer.com. All rights reserved.
//

#import "WebQuery.h"

#import "CronometerAppDelegate.h"
#import "Toolbox.h"
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"
#import "NSDictionary_JSONExtensions.h" 
#import "UIApplication+NetworkActivity.h"

@implementation WebQuery 


+ (WebQuery *) singleton {
    static WebQuery *sharedWebQueryInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedWebQueryInstance = [[self alloc] init];
    });
    return sharedWebQueryInstance;
}

- (id)init {
   self = [super init];
   if (self) {      
      [self initCaches];
   }   
   return self;
}


- (void) initCaches {
   self.foodCache = [[NSMutableDictionary alloc] init];
   self.activityCache = [[NSMutableDictionary alloc] init];
   self.metricsCache = [[NSMutableDictionary alloc] init];
   self.nutrientsCache = [[NSMutableDictionary alloc] init];
   self.prefsCache = [[NSMutableDictionary alloc] init];
}

-(NSString *)formatAuthKey {
   NSString *str = [NSString stringWithFormat:@"%ld_%qx=[NaCl]=", _userId, _sessionKey];
   NSData *data = [Toolbox sha256: [str dataUsingEncoding:NSUTF8StringEncoding]]; 
   return [Toolbox urlEncode: [Toolbox encode:data]];
}


- (NSDictionary *) serviceCall: (NSString *)params {
   if (!self.isLoggedIn) {
      self.lastError = @"Not Logged In";
     	NSLog(@"Service call failed: %@", self.lastError);
      return nil;
   }
   return [self serviceCallImpl: params];
}

- (NSDictionary *) serviceCallImpl: (NSString *)params {
   self.lastError = @"";
   NSError *anError = nil;
   
   NSString *myRequestString = [NSString stringWithFormat:@"%@?user=%ld&auth=%@&ver=%@&%@", @BASE_URL, _userId, [self formatAuthKey], @VERSION, params];
   NSLog(@"REQUEST=%@", myRequestString);
   
   [[UIApplication sharedApplication] showNetworkActivityIndicator];
   
   NSString *responseString = [NSString stringWithContentsOfURL: [NSURL URLWithString:myRequestString] encoding:NSUTF8StringEncoding error:&anError];
   if (anError != nil) {
     	NSLog(@"Request failed: %@", [anError description]);
      return nil;
   }   
   NSLog(@"RESPONSE=%@", responseString); 
   
   [[UIApplication sharedApplication] hideNetworkActivityIndicator];
   
   NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:responseString error:&anError];   
   if (anError != nil) {
     	NSLog(@"Parse failed: %@", [anError description]);
      return nil;
   } else {
      if ([[theDictionary objectForKey:@"result"] isEqualToString:@"FAIL"]) {
         self.lastError = [theDictionary objectForKey:@"error"];
         NSLog(@"FAIL: %@", self.lastError);
         
         if ([self.lastError isEqualToString:@"Not Logged In"] || [self.lastError isEqual:@"Authentication failed"]) {
            [Toolbox showMessage:self.lastError withTitle:@"Error"];
            DiaryViewController *diary = [DiaryViewController singleton];
            if (diary != nil) {
               [diary logout];
            }
         }
         return nil;
      }
   }
   return theDictionary;
}

// a service call with no user authentication
-(NSDictionary *) publicServiceCall: (NSString *)params {
   self.lastError = @"";
   NSError *anError = nil;
   
   NSString *myRequestString = [NSString stringWithFormat:@"%@?&ver=%@&%@", @BASE_URL, @VERSION, params];
   NSLog(@"REQUEST=%@", myRequestString);
   
   [[UIApplication sharedApplication] showNetworkActivityIndicator];
   
   NSString *responseString = [NSString stringWithContentsOfURL: [NSURL URLWithString:myRequestString] encoding:NSUTF8StringEncoding error:&anError];
   if (anError != nil) {
     	NSLog(@"Request failed: %@", [anError description]);
      return nil;
   }
   NSLog(@"RESPONSE=%@", responseString);
   
   [[UIApplication sharedApplication] hideNetworkActivityIndicator];
   
   NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:responseString error:&anError];
   if (anError != nil) {
     	NSLog(@"Parse failed: %@", [anError description]);
      return nil;
   }
   return theDictionary;
}


- (bool) isLoggedIn {
   return self.sessionKey != 0 && self.userId != 0;
}

- (bool) needsAccountSetup {
   return [self getPref:@"weightInKG" defaultTo:nil] == nil;
}


- (void) logout {
   if (_sessionKey != 0) {
      [self serviceCall: @"action=logout"];
   }
   dispatch_async(dispatch_get_main_queue(), ^{
      if (FBSession.activeSession.isOpen) {
         [FBSession.activeSession closeAndClearTokenInformation];
      }
   });
   self.sessionKey = 0;
   self.userId = 0;
   // clear prefs
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:[NSNumber numberWithLong: 0] forKey: @"uid"];
   [defaults removeObjectForKey: @"FBAccessTokenKey"];   
   [defaults synchronize]; 

   // clear caches on logout
   [self initCaches];
}

- (void) readFromDictionary: (NSDictionary *) dict {      
   self.userId = [[dict objectForKey:@"id"] longValue];
   self.sessionKey = [[dict objectForKey:@"session"] longLongValue];

   [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLong: self.userId] forKey: @"uid"];
   [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithLongLong:self.sessionKey] forKey:@"authkey"];
   [[NSUserDefaults standardUserDefaults] synchronize];

   self.gold = [[dict objectForKey:@"gold"] boolValue];
   self.age = [[dict objectForKey:@"age"] integerValue];
   self.gender = [dict objectForKey:@"gender"]; 
   
   NSArray *items = [dict objectForKey:@"prefs"];
   for (NSDictionary *itemDict in items) {
      for (id key in [itemDict keyEnumerator]) {
         //NSLog(@"   PREF {%@ ==> %@}", key, [itemDict objectForKey:key]);   
         [_prefsCache setObject: [itemDict objectForKey:key] forKey: key ];
      }       
   }
   
   self.weightInKg = [self getDoublePref:@"weightInKG" defaultTo: 70.0];
   self.heightInCM = [self getDoublePref:@"heightInCM" defaultTo: 160.0];
   //self.gender = [self getPref:@"gender" defaultTo:@"Male"];
   
   [[Crashlytics sharedInstance] setUserIdentifier:[dict objectForKey:@"id"]];
   
}

- (BOOL) setPref:(NSString *)key withValue:(NSString *)val {
   NSString *current =  [_prefsCache objectForKey:key];
   if (current != nil && val != nil) {
      if ([[NSString stringWithFormat:@"%@", current] isEqualToString: val]) {
         return TRUE;
      }
   }
   NSLog(@"SetPref: %@ => %@", key, val);
    if (val == nil) return false;
   [_prefsCache setObject:val forKey: key];
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=set_pref&key=%@&val=%@", [Toolbox urlEncode:key], [Toolbox urlEncode:val]]];
   return (dict != nil);
}

- (NSString*) getPref: (NSString*) key defaultTo: (NSString*) def {
   NSString *value = [_prefsCache objectForKey:key];
   if (value == nil) {
      value = def;      
   }
   return value;
}

- (NSInteger) getIntPref: (NSString*) key defaultTo: (NSInteger) def {
   NSString *value = [_prefsCache objectForKey:key];
   if (value == nil) {
      return def;
   }
   return [value intValue];
}

- (double) getDoublePref: (NSString*) key defaultTo: (double) def {
   NSString *value = [_prefsCache objectForKey:key];
   if (value == nil) {
      return def;
   }
   return [value doubleValue];
}

- (bool) getBoolPref: (NSString*) key defaultTo: (bool) def {
   NSString *value = [_prefsCache objectForKey:key];
   if (value == nil) {
      return def;
   }
   return [value isEqualToString:@"true"];
}

- (double) weightInPounds {
   return self.weightInKg / 0.45359237038;
}

- (double) weightInPreferredUnit {
   return  [self getPreferredWeightUnit] == 1 ? [self weightInKg] : [self weightInPounds];
}
- (double) heightInPreferredUnit {
    return  [self getPreferredHeightUnit] == 3 ? [self heightInCM] : [self heightInCM]/2.54;
}

- (long) getPreferredWeightUnit {
    return [[self getPref:@"weightUnit" defaultTo: @"Kilograms"] isEqualToString: @"Pounds"] ? 2 : 1;
}

- (long) getPreferredHeightUnit {
    return [[self getPref:@"heightUnit" defaultTo: @"Centimeters"] isEqualToString: @"Inches"] ? 4 : 3; // make it consitant to unit id.
}

-(void)login:(NSString *)email password:(NSString *)password {
   [self login:email password:password command:@"login"];
}

-(void)createAccount:(NSString *)email password:(NSString *)password {
   [self login:email password:password command:@"email"];
}

-(void)login:(NSString *)email password:(NSString *)password command:(NSString *)command {
   NSString *myRequestString = [NSString stringWithFormat:@"&%@=%@&password=%@", command, [Toolbox urlEncode: email], [Toolbox urlEncode: password]];
   NSData *myRequestData = [NSData dataWithBytes: [myRequestString UTF8String] length: [myRequestString length]];
   
   [[UIApplication sharedApplication] showNetworkActivityIndicator];
   
   NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: @BASE_URL]];
   [request setHTTPMethod: @"POST"];
   [request setHTTPBody: myRequestData];
    NSError* error = nil;
   NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: &error];
   NSString *responseString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
   NSLog(@"RESPONSE=%@", responseString);
   
   [[UIApplication sharedApplication] hideNetworkActivityIndicator];
   
   NSError *theError = nil; 
   NSDictionary *theDictionary = [NSDictionary dictionaryWithJSONString:responseString error:&theError];
    
   if (theError != nil) {
     	NSLog(@"Parse failed: %@", [theError localizedDescription]);
   } else {      
      if ([[theDictionary objectForKey:@"result"] isEqualToString: @"FAIL"]) {
         self.lastError = [theDictionary objectForKey:@"error"];
      } else {      
         [self readFromDictionary: theDictionary];
         [self loadMetrics];
         [self loadTargets];
      }
   } 
}


-(void)relogin {
   [self relogin: self.sessionKey user: self.userId];
}


-(void)relogin:(long long)sKey user:(long)uid {
   self.sessionKey = sKey;
   self.userId = uid;
   NSDictionary *dict = [self serviceCallImpl: @"action=login"];
   if (dict != nil) {
      [self readFromDictionary: dict];
      [self loadMetrics];
      [self loadTargets];
   } else {
      self.sessionKey = 0;
      self.userId = 0;      
   }
}

- (void) facebookLogin: (NSString *)access_token {
   NSDictionary *dict = [self serviceCallImpl: [NSString stringWithFormat:@"action=fblogin&access_token=%@", access_token]];
   if (dict != nil) {
      [self readFromDictionary: dict];
      [self loadMetrics];    
      [self loadTargets];    
   } else {
      self.sessionKey = 0;
      self.userId = 0;
      dispatch_async(dispatch_get_main_queue(), ^{
         [FBSession.activeSession closeAndClearTokenInformation];
      });
   }
}
- (void) markDayCompleted: (Day*) day completed: (BOOL) completed {
    [self serviceCall: [NSString stringWithFormat:@"action=set_complete&day=%@&complete=%@", day, (completed==YES?@"true":@"false")]];
}
- (Diary*) getDiary: (Day*)day {
    NSMutableArray *results = nil;
    Summary* summary = nil;
    Diary* diary = nil;
    NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=get_diary&day=%@", day]];
    if (dict != nil) {
        
        NSArray *items = [dict objectForKey:@"diary"];
        results = [[NSMutableArray alloc] initWithCapacity: [items count]];
        for (NSDictionary *itemDict in items) {
            NSString *type = [itemDict objectForKey:@"type"];
            if ([type isEqualToString:@"Serving"]) {
                [self getFood: [[itemDict objectForKey:@"fid"] longValue]];
                [results addObject: [[Serving alloc] initWithDictionary: itemDict]];
            } else if ([type isEqualToString:@"Exercise"]) {
                [self getActivity: [[itemDict objectForKey:@"aid"] longValue]];
                [results addObject: [[Exercise alloc] initWithDictionary: itemDict]];
            } else if ([type isEqualToString:@"Measurement"]) {
                [results addObject: [[Biometric alloc] initWithDictionary: itemDict]];
            } else if ([type isEqualToString:@"Note"]) {
                [results addObject: [[Note alloc] initWithDictionary: itemDict]];
            }
        }
        // TODO: Load all foods in parallel instead of in series
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //});
        summary = [self updateSummaryWith: dict];
        diary = [[Diary alloc] init];
        diary.summary = summary;
        diary.diaryEntries = results;
        NSDictionary* info = [dict objectForKey: @"info"];
        if (info != nil) {
            NSNumber * isCompleted = (NSNumber *)[info objectForKey: @"complete"] ;
            if ([isCompleted boolValue] == YES) {
                diary.completed = YES;
                //diary.completed = (([completedString isEqualToString:@"1"]) ? YES : NO) ;
            }else{
                diary.completed = NO;
            }
        }
    }
    return diary;
}

- (Summary*) getSummary: (Day*)day {
//    Summary* summary = nil;

    NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=get_summary&day=%@", day]];
    return [self updateSummaryWith: dict];
}

-(NSArray *)getDiaryEntries:(Day *)day {
   NSMutableArray *results = nil;
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=get_diary&day=%@", day]];
   if (dict != nil) {
      
      NSArray *items = [dict objectForKey:@"diary"];
      results = [[NSMutableArray alloc] initWithCapacity: [items count]];
      for (NSDictionary *itemDict in items) {
         NSString *type = [itemDict objectForKey:@"type"];
         if ([type isEqualToString:@"Serving"]) {
            [self getFood: [[itemDict objectForKey:@"fid"] longValue]];
            [results addObject: [[Serving alloc] initWithDictionary: itemDict]];         
         } else if ([type isEqualToString:@"Exercise"]) {
            [self getActivity: [[itemDict objectForKey:@"aid"] longValue]];
            [results addObject: [[Exercise alloc] initWithDictionary: itemDict]];    
         } else if ([type isEqualToString:@"Measurement"]) {
            [results addObject: [[Biometric alloc] initWithDictionary: itemDict]]; 
         } else if ([type isEqualToString:@"Note"]) {
            [results addObject: [[Note alloc] initWithDictionary: itemDict]];       
         }
      }
      // TODO: Load all foods in parallel instead of in series
      //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{         
      //});    
   }                         
   return results;
}

- (Summary*) updateSummaryWith: (NSDictionary*) dict {
    Summary* summary = [[Summary alloc] init];
    NSDictionary* summaryDict = [dict objectForKey: @"summary"];
    if (summaryDict == nil)
        return  summary;
    
    NSDictionary* burnedDict = [summaryDict objectForKey:@"burned"];
    if (burnedDict != nil) {
        Burned* burned = [[Burned alloc] init];
        NSNumber* total = (NSNumber*)[burnedDict objectForKey:@"total"];
        if (total) {
            burned.total = [total doubleValue];
        }
        NSNumber* surplus_percent = (NSNumber*)[burnedDict objectForKey:@"surplus_percent"];
        if (surplus_percent) {
            burned.surplus_percent = [surplus_percent doubleValue];
        }
        NSNumber* surplus_kcal = (NSNumber*)[burnedDict objectForKey:@"surplus_kcal"];
        if (surplus_kcal) {
            burned.surplus_kcal = [surplus_kcal doubleValue];
        }
        NSNumber* activity_percent = (NSNumber*)[burnedDict objectForKey:@"activity_percent"];
        if (activity_percent) {
            burned.activity_percent = [activity_percent doubleValue];
        }
        NSNumber* exercise_percent = (NSNumber*)[burnedDict objectForKey:@"exercise_percent"];
        if (exercise_percent) {
            burned.exercise_percent = [exercise_percent doubleValue];
        }
        NSNumber* exercise_kcal = (NSNumber*)[burnedDict objectForKey:@"exercise_kcal"];
        if (exercise_kcal) {
            burned.exercise_kcal = [exercise_kcal doubleValue];
        }
        NSNumber* bmr_kcal = (NSNumber*)[burnedDict objectForKey:@"bmr_kcal"];
        if (bmr_kcal) {
            burned.bmr_kcal = [bmr_kcal doubleValue];
        }
        NSNumber* activity_kcal = (NSNumber*)[burnedDict objectForKey:@"activity_kcal"];
        if (activity_kcal) {
            burned.activity_kcal = [activity_kcal doubleValue];
        }
        NSNumber* bmr_percent = (NSNumber*)[burnedDict objectForKey:@"bmr_percent"];
        if (bmr_percent) {
            burned.bmr_percent = [bmr_percent doubleValue];
        }
        summary.burned = burned;
    }
    NSDictionary* consumedDict = [summaryDict objectForKey:@"consumed"];
    if (consumedDict != nil) {
        Consumed* consumed = [[Consumed alloc] init];
        NSNumber*  consumed_total = (NSNumber*) [consumedDict objectForKey: @"total"];
        if (consumed_total) {
            consumed.total = [consumed_total doubleValue];
        }
        NSNumber*  fat_kcal = (NSNumber*) [consumedDict objectForKey: @"fat_kcal"];
        if (fat_kcal) {
            consumed.fat_kcal = [fat_kcal doubleValue];
        }
        NSNumber*  protein_percent = (NSNumber*) [consumedDict objectForKey: @"protein_percent"];
        if (protein_percent) {
            consumed.protein_percent = [protein_percent doubleValue];
        }
        NSNumber*  carbs_percent = (NSNumber*) [consumedDict objectForKey: @"carbs_percent"];
        if (carbs_percent) {
            consumed.carbs_percent = [carbs_percent doubleValue];
        }
        NSNumber*  fat_percent = (NSNumber*) [consumedDict objectForKey: @"fat_percent"];
        if (fat_percent) {
            consumed.fat_percent = [fat_percent doubleValue];
        }
        NSNumber*  deficit_percent = (NSNumber*) [consumedDict objectForKey: @"deficit_percent"];
        if (deficit_percent) {
            consumed.deficit_percent = [deficit_percent doubleValue];
        }
        NSNumber*  alcohol_kcal = (NSNumber*) [consumedDict objectForKey: @"alcohol_kcal"];
        if (alcohol_kcal) {
            consumed.alcohol_kcal =[alcohol_kcal doubleValue];
        }
        NSNumber*  alcohol_percent = (NSNumber*) [consumedDict objectForKey: @"alcohol_percent"];
        if (alcohol_percent) {
            consumed.alcohol_percent = [alcohol_percent doubleValue];
        }
        NSNumber*  carbs_kcal = (NSNumber*) [consumedDict objectForKey: @"carbs_kcal"];
        if (carbs_kcal) {
            consumed.carbs_kcal = [carbs_kcal doubleValue];
        }
        NSNumber*  deficit_kcal = (NSNumber*) [consumedDict objectForKey: @"deficit_kcal"];
        if (deficit_kcal) {
            consumed.deficit_kcal = [deficit_kcal doubleValue];
        }
        NSNumber*  protein_kcal = (NSNumber*) [consumedDict objectForKey: @"protein_kcal"];
        if (protein_kcal) {
            consumed.protein_kcal = [protein_kcal doubleValue];
        }
        summary.consumed = consumed;
    }
    NSNumber* weight_goal = (NSNumber*)[summaryDict objectForKey:@"weight_goal"];
    if (weight_goal) {
        summary.weight_goal = [weight_goal doubleValue];
    }
    return summary;
}

-(void) loadTargets {
   @synchronized(self) {
      self.targetsCache = [[NSMutableDictionary alloc] init];
      NSDictionary *dict = [self serviceCall: @"action=get_targets"];
      if (dict != nil) {
         NSArray *items = [dict objectForKey:@"targets"];
         for (NSDictionary *itemDict in items) {
            Target *target = [[Target alloc] init: itemDict];
            if (target != nil) {
               [_targetsCache setObject: target forKey: @(target.nutrientId)];
            }
         }
      }
   }
} 

// gets a target by nutrientId
-(Target *) target: (long)nutrientId {
   @synchronized(self) {
      if (_targetsCache == nil) {
         [self loadTargets];
      }
      return [_targetsCache objectForKey:@(nutrientId)];
   }
}

// get a list of targets
- (NSArray *) getTargets {
   @synchronized(self) {
      if (_targetsCache == nil) {
         [self loadTargets];
         return [NSArray array]; // return empty array
      }
      return [_targetsCache allValues];
   }
}

// copies all targets from dict into our target cache
-(void) updateTargets:(NSDictionary*)dict {
   if (dict != nil) {
      NSArray *items = [dict objectForKey:@"targets"];
      for (NSDictionary *itemDict in items) {
         Target *target = [[Target alloc] init: itemDict];
         if (target != nil) {
            [_targetsCache setObject: target forKey: @(target.nutrientId)];
         }
      }
   }
}

- (void) suggestTargets {
   @synchronized(self) {
      self.targetsCache = [[NSMutableDictionary alloc] init];
      NSDictionary *dict = [self serviceCall: @"action=suggest_targets"];
     [self updateTargets:dict];
   }
}

- (Target *) suggestTarget:(long)nutrientId {
   @synchronized(self) {
      NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=suggest_targets&id=%ld", nutrientId]];
      [self updateTargets:dict];
      return _targetsCache[@(nutrientId)];
   }
}

-(void) warmCaches {
   [self serviceCall: @"action=warm_cache"];
}

-(void) loadMetrics {
   @synchronized(self) {
      NSDictionary *dict = [self serviceCall: @"action=get_metrics"];
      if (dict != nil) {      
         NSArray *items = [dict objectForKey:@"metrics"];
         for (NSDictionary *itemDict in items) {
            Metric *metric = [[Metric alloc] init];
            [metric readFromDict:itemDict];
            [_metricsCache setObject: metric forKey: @(metric.mId)];
         }      
      }
   }
}

// get a sorted list of metrics
- (NSArray *) getMetrics {
   @synchronized(self) {
      if ([_metricsCache count] == 0) {
         [self loadMetrics];
      }
      return [[_metricsCache allValues] sortedArrayUsingComparator:
              (NSComparator)^(Metric *obj1, Metric *obj2) { 
                  return  obj1.mId - obj2.mId;
               } ];
   }
}

// gets a metric by metricId
-(Metric *) metric: (long)mId {
   @synchronized(self) {
      if ([_metricsCache count] == 0) {
         [self loadMetrics];
      }
      return _metricsCache[@(mId)];
   }
}

-(void) loadNutrients {
   @synchronized(self) {
      NSDictionary *dict = [self serviceCall: @"action=nutrientinfo"];
      if (dict != nil) {      
         NSArray *items = [dict objectForKey:@"nutrients"];
         for (NSDictionary *itemDict in items) {
            NutrientInfo *ni = [[NutrientInfo alloc] init];
            [ni readFromDict:itemDict];
            [_nutrientsCache setObject: ni forKey:@(ni.nId)];
         }      
      }
   }
}

// get a sorted list of nutrients
- (NSArray *) getNutrients {
   @synchronized(self) {
      if ([_nutrientsCache count] == 0) {
         [self loadNutrients];
      }
      return [[_nutrientsCache allValues] sortedArrayUsingComparator:
              ^NSComparisonResult(id obj1, id obj2) {
                    NutrientInfo *ni1 = obj1;
                    NutrientInfo *ni2 = obj2;
                  return [[ni1 description] compare:[ni2 description] options:NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
                } ];
   }
}

// gets a nutrient by nutrient id
-(NutrientInfo *) nutrient: (long)nId {
   @synchronized(self) {
      if ([_nutrientsCache count] == 0) {
         [self loadNutrients];
      }
      return [_nutrientsCache objectForKey:@(nId)];
   }
}


-(Food *)getFood:(long)foodId {
   Food *food = nil;
   // check cache for food
   if (_foodCache != nil) {
      food = [_foodCache objectForKey:@(foodId)];
   }
   if (food == nil) {
      // cache miss, so fetch from the server
      NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=get_food&id=%ld", foodId]];
      if (dict != nil) {
         food = [[Food alloc] initWithDictionary: dict];
         if (food != nil && _foodCache != nil) {
            // cache object for later
            CLS_LOG(@"GetFood %ld, food = %@, foodCache = %@", foodId, food, _foodCache);
            [_foodCache setObject: food forKey: @(foodId)];
         }
      }
   }
   return food;
}

-(Activity *)getActivity:(long)aId {
   Activity *act = nil;
   if (aId != 0) {
      // check cache for Activity 
      act = [_activityCache objectForKey:@(aId)];
      if (act == nil) {
         // cache miss, so fetch from the server
         NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=get_activity&id=%ld", aId]];
         if (dict != nil) {
            act = [[Activity alloc] initWithDictionary: dict];
            // cache object for later
            [_activityCache setObject: act forKey: @(aId)];
         }
      }
   }
   return act;
}

- (NSArray *) topFoods {
   NSMutableArray *results = nil;
   NSDictionary *dict = [self serviceCall: @"action=get_topfoods"];
   if (dict != nil) {      
      NSArray *items = [dict objectForKey:@"foods"];
      results = [[NSMutableArray alloc] initWithCapacity: [items count]];
      for (NSDictionary *itemDict in items) { 
         [results addObject: [[SearchHit alloc] init: itemDict]];
      }
   }                         
   return results; 
}

- (NSArray *) topActivities {
   NSMutableArray *results = nil;
   NSDictionary *dict = [self serviceCall: @"action=get_topactivities"];
   if (dict != nil) {      
      NSArray *items = [dict objectForKey:@"activities"];
      results = [[NSMutableArray alloc] initWithCapacity: [items count]];
      for (NSDictionary *itemDict in items) { 
         [results addObject: [[Activity alloc] initWithDictionary: itemDict]];
      }
   }  
   return results; 
}

- (long) searchFoodByBarcode: (NSString*) barcode {
    NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=barcode&query=%@", [Toolbox urlEncode:barcode]]];
    if (dict == nil) {
        return -1;
    }
    NSNumber* foodId = [dict objectForKey:@"foodId"];
    if (foodId != nil) {
        return [foodId longValue];
    }
    NSString* result = [dict objectForKey:@"result"];
    if (result != nil) {
        if ([result isEqualToString:@"SUCCESS"]) {
            return 0;
        }
    }
    return -1;
}

- (NSArray *) findFoods: (NSString *)str {
   NSMutableArray *results = nil;
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=find_food&query=%@", [Toolbox urlEncode:str]]];
   if (dict != nil) { 
      NSArray *items = [dict objectForKey:@"foods"];
      results = [[NSMutableArray alloc] initWithCapacity: [items count]];
      for (NSDictionary *itemDict in items) {
         [results addObject: [[SearchHit alloc] init: itemDict]];
      }
   }                         
   return results; 
}
- (NSDictionary*) foodStats: (long)foodid {
    NSDictionary* dict = [self serviceCall: [NSString stringWithFormat:@"action=food_stats&id=%ld", foodid]];
    return dict;
}

- (BOOL) delFood: (Food*) food {
    if (food == nil) {
        return NO;
    }
    long foodid = food.foodId;
    NSDictionary* dict = [self serviceCall: [NSString stringWithFormat:@"action=del_food&id=%ld", food.foodId]];
    if (dict != nil) {
        NSString* result = dict[@"result"];
        if (result != nil && [result isEqualToString: @"SUCCESS"]) {
            [self.foodCache removeObjectForKey:@(foodid)];
            return YES;
        }
    }
    return NO;
}

- (NSArray *) findActivities: (NSString *)str {
   NSMutableArray *results = nil;
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=find_activity&query=%@", [Toolbox urlEncode:str]]];
   if (dict != nil) { 
      NSArray *items = [dict objectForKey:@"activities"];
      results = [[NSMutableArray alloc] initWithCapacity: [items count]];
      for (NSDictionary *itemDict in items) {
         [results addObject: [[Activity alloc] initWithDictionary: itemDict]];
      }
   }                         
   return results; 
}
 
-(long)addServing:(Serving *)serving {
   long entryId = 0;
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=add_serving&day=%@&food=%ld&measure=%ld&amount=%f&order=%ld", [serving day], serving.foodId, serving.mId, serving.amount, serving.order]];
   if (dict != nil) { 
      entryId = [[dict objectForKey:@"id"] longValue];
      serving.entryId = entryId;
   }                         
   return entryId;  
}

-(long)addExercise:(Exercise *)exercise {
   long entryId = 0;
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=add_exercise&day=%@&minutes=%f&activity=%ld&order=%ld", [exercise day], exercise.minutes, exercise.aId, exercise.order]];
   if (dict != nil) { 
      entryId = [[dict objectForKey:@"id"] longValue];
      exercise.entryId = entryId;
   } 
   return entryId;  
}

-(long)addBiometric:(Biometric *)biometric {
   long entryId = 0;
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=add_biometric&day=%@&amount=%f&mid=%ld&uid=%ld&order=%ld", [biometric day], biometric.amount, biometric.mId, biometric.uId, biometric.order]];
   if (dict != nil) { 
      entryId = [[dict objectForKey:@"id"] longValue];
      biometric.entryId = entryId;
      [self updateCurrentWeightAndHeight: dict];
   }
   return entryId;  
}

- (void) updateCurrentWeightAndHeight: (NSDictionary *)dict {
   if ([dict objectForKey:@"weightInKG"]) {
      [_prefsCache setObject:[dict objectForKey:@"weightInKG"] forKey: @"weightInKG" ];
      self.weightInKg = [self getDoublePref:@"weightInKG" defaultTo: self.weightInKg];
   }
   if ([dict objectForKey:@"heightInCM"]) {
      [_prefsCache setObject:[dict objectForKey:@"heightInCM"] forKey: @"heightInCM"];
      self.heightInCM = [self getDoublePref:@"heightInCM" defaultTo: self.heightInCM];
   }
}

-(long)addNote:(Note *)note {
   long entryId = 0;
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=add_note&day=%@&text=%@&order=%ld", [note day], [Toolbox urlEncode:note.text], note.order]];
   if (dict != nil) { 
      entryId = [[dict objectForKey:@"id"] longValue];
      note.entryId = entryId;
   }                         
   return entryId;  
}
 
-(BOOL)editServing:(Serving *)serving {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=edit_serving&id=%ld&food=%ld&measure=%ld&amount=%f&order=%ld", [serving entryId], serving.foodId, serving.mId, serving.amount, serving.order]];
   return (dict != nil);
}

-(BOOL)editExercise:(Exercise *)exercise {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=edit_exercise&id=%ld&minutes=%f&activity=%ld&order=%ld", [exercise entryId], exercise.minutes, exercise.aId, exercise.order]];
   return (dict != nil);
} 

-(BOOL)editNote:(Note *)note {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=edit_note&id=%ld&text=%@&order=%ld", [note entryId], [Toolbox urlEncode:note.text], note.order]];
   return (dict != nil);
}

-(BOOL)editBiometric:(Biometric *)biometric {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=edit_biometric&id=%ld&amount=%f&mid=%ld&uid=%ld&order=%ld", [biometric entryId], biometric.amount, biometric.mId, biometric.uId, biometric.order]];
   if (dict != nil) {
     [self updateCurrentWeightAndHeight: dict];
   }
   return (dict != nil);
}

- (BOOL) editTarget:(Target*)target {
   NSDictionary *dict = nil;
   if (target.min != nil && target.max != nil) {
      dict = [self serviceCall: [NSString stringWithFormat:@"action=edit_target&id=%ld&min=%f&max=%f", target.nutrientId, [target.min doubleValue], [target.max doubleValue]]];
   } else if (target.min == nil && target.max != nil) {
      dict = [self serviceCall: [NSString stringWithFormat:@"action=edit_target&id=%ld&max=%f", target.nutrientId,  [target.max doubleValue]]];
   } else if (target.min != nil && target.max == nil) {
      dict = [self serviceCall: [NSString stringWithFormat:@"action=edit_target&id=%ld&min=%f", target.nutrientId,  [target.min doubleValue]]];
   } else {
      dict = [self serviceCall: [NSString stringWithFormat:@"action=edit_target&id=%ld", target.nutrientId]];
   }
   return (dict != nil);
}

- (BOOL) editEntry:(DiaryEntry *)entry {
   if (entry) {
      if ([entry isKindOfClass: [Serving class]]) { 
         return [self editServing: (Serving *)entry];
      } else if ([entry isKindOfClass: [Exercise class]]) { 
         return [self editExercise: (Exercise *)entry];
      } else if ([entry isKindOfClass: [Biometric class]]) { 
         return [self editBiometric: (Biometric *)entry];
      } else if ([entry isKindOfClass: [Note class]]) { 
         return [self editNote: (Note *)entry];
      }
   }
   return FALSE;
}

-(BOOL)deleteServing:(Serving *)serving {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=del_serving&id=%ld", [serving entryId]]];
   return (dict != nil);
}

-(BOOL)deleteExercise:(Exercise *)exercise {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=del_exercise&id=%ld", [exercise entryId]]];
   return (dict != nil);
} 

-(BOOL)deleteNote:(Note *)note {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=del_note&id=%ld", [note entryId]]];
   return (dict != nil);
}

-(BOOL)deleteBiometric:(Biometric *)biometric {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=del_biometric&id=%ld", [biometric entryId]]];   
   return (dict != nil);
}

- (BOOL)copyFrom:(Day*)fromDay to:(Day*)toDay {
   NSDictionary *dict = [self serviceCall: [NSString stringWithFormat:@"action=copy&from=%@&to=%@", fromDay, toDay]];
   if (dict != nil) {
      [self updateCurrentWeightAndHeight: dict];
   }
   return (dict != nil);
}

- (double) getBMR {
   double cm = _heightInCM;
   double kg = _weightInKg;
   if ([_gender isEqualToString:@"Male"]) {
      return 88.362 + (13.397 * kg) + (4.799 * cm) - (5.677 * _age);
   } else {
      return 447.593 + (9.247 * kg) + (3.098 * cm) - (4.330 * _age);
   }
}

-(long)addFood:(Food *)food {
   NSError *error = NULL;
   NSData *theJSONData = [[CJSONSerializer serializer] serializeDictionary:[food toDictionary] error:&error];
   if (error) {
      NSLog(@"Serialization Error: %@", error);
   } else {
      NSString* jsonString = [[NSString alloc] initWithData:theJSONData encoding:NSUTF8StringEncoding];
      NSLog(@"JSON = %@", jsonString);
      NSDictionary *response = [self serviceCall: [NSString stringWithFormat:@"action=add_food&data=%@", [Toolbox urlEncode:jsonString]]];
      if (response != nil) {
         food.foodId = [response[@"id"] longValue];
         return food.foodId;
      }
   }
   return 0;
}

- (NSDictionary*) resetPassword:(NSString *)email {
   NSDictionary *dict = [self publicServiceCall: [NSString stringWithFormat:@"action=reset_password&email=%@", [Toolbox urlEncode:email]]];
   return dict;
}


@end
