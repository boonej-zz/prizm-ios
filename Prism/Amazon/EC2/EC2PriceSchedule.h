/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */




/**
 * Price Schedule
 */

@interface EC2PriceSchedule:NSObject

{
    NSNumber *term;
    NSNumber *price;
    NSString *currencyCode;
    BOOL     active;
    BOOL     activeIsSet;
}




/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;

/**
 * The value of the Term property for this object.
 */
@property (nonatomic, retain) NSNumber *term;

/**
 * The value of the Price property for this object.
 */
@property (nonatomic, retain) NSNumber *price;

/**
 * The value of the CurrencyCode property for this object.
 * <p>
 * <b>Constraints:</b><br/>
 * <b>Allowed Values: </b>USD
 */
@property (nonatomic, retain) NSString *currencyCode;

/**
 * The value of the Active property for this object.
 */
@property (nonatomic) BOOL           active;

@property (nonatomic, readonly) BOOL activeIsSet;

/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;


@end