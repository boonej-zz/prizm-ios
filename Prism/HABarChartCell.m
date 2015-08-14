//
//  HABarChartCell.m
//  Prizm
//
//  Created by Jonathan Boone on 8/12/15.
//  Copyright (c) 2015 Higher Altitude. All rights reserved.
//

#import "HABarChartCell.h"
#import "CorePlot-CocoaTouch.h"


@interface HABarChartCell()<CPTBarPlotDataSource, CPTBarPlotDelegate>

@property (nonatomic, strong) CPTGraphHostingView *graphView;
@property (nonatomic, strong) CPTBarPlot *plot;
@property (nonatomic, strong) NSArray *keys;

@end

@implementation HABarChartCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark Configuration

- (void)setupViews
{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectedBackgroundView:[[UIView alloc] init]];
    self.graphView = [[CPTGraphHostingView alloc] initWithFrame:CGRectZero];
    [self.graphView setBackgroundColor:[UIColor purpleColor]];
    [self.graphView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.graphView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.graphView];
   
    
}

- (void)setupConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.graphView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.graphView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.graphView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.graphView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
}

- (void)setPlotData:(NSDictionary *)plotData
{
    _plotData = plotData;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M/d"];
    self.keys = [[plotData allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[df dateFromString:obj1] compare:[df dateFromString:obj2]];
    }];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
   
    CPTGraph *graph =  (CPTGraph *)[theme newGraph];

    graph.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    [graph setFrame:self.graphView.bounds];
    self.graphView.hostedGraph = graph;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor colorWithCGColor:[UIColor HATextColor].CGColor];
    textStyle.fontName = @"HelveticaNeue-Bold";
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    [lineStyle setLineColor:[CPTColor colorWithCGColor:[UIColor HATextColor].CGColor]];
    [lineStyle setLineWidth:1.f];

    self.plot = [[CPTBarPlot alloc] init];

    [graph setPaddingTop:0];
    [graph setPaddingBottom:0];
    [graph setPaddingLeft:0];
    [graph setPaddingRight:0];

    [self.plot setDataSource:self];
    [self.plot setDelegate:self];
    [self.plot setBarWidthsAreInViewCoordinates:YES];
    [self.plot setLineStyle:nil];

    self.plot.barWidth = [@40 decimalValue];
    CPTXYPlotSpace *ps = (CPTXYPlotSpace *)[graph defaultPlotSpace];
    int count = 4;
    [ps setXRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(count)]];
    [ps setYRange:[self yRange]];
  
    [[graph plotAreaFrame] setPaddingLeft:44.0f];
    [[graph plotAreaFrame] setPaddingTop:34.0f];
    [[graph plotAreaFrame] setPaddingBottom:25.0f];
    [[graph plotAreaFrame] setPaddingRight:16.0f];
    [[graph plotAreaFrame] setBorderLineStyle:nil];

    
    [textStyle setFontSize:9.0f];
    [textStyle setColor:[CPTColor colorWithCGColor:[[UIColor grayColor] CGColor]]];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)[graph axisSet];
    
    CPTXYAxis *xAxis = [axisSet xAxis];
 
    [xAxis setMajorIntervalLength:CPTDecimalFromInt(1)];
    [xAxis setMinorTickLineStyle:nil];
    [xAxis setLabelingPolicy:CPTAxisLabelingPolicyNone];
    [xAxis setLabelTextStyle:textStyle];
    [xAxis setAxisLineStyle:lineStyle];
    [xAxis setMajorTickLineStyle:nil];
    
    NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:1], [NSDecimalNumber numberWithInt:2], [NSDecimalNumber numberWithInt:3],  nil];
    NSArray *xAxisLabels = self.keys;
    NSUInteger labelLocation = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    xAxis.labelOffset = -3;
    for (NSNumber *tickLocation in customTickLocations) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [xAxisLabels objectAtIndex:labelLocation++] textStyle:xAxis.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset = xAxis.labelOffset + xAxis.majorTickLength;
        [customLabels addObject:newLabel];
    }
    xAxis.axisLabels = [NSSet setWithArray:customLabels];

    
    CPTXYAxis *yAxis = [axisSet yAxis];
    [yAxis setMajorIntervalLength:CPTDecimalFromInt(1)];
    [yAxis setMinorTickLineStyle:nil];
    [yAxis setLabelingPolicy:CPTAxisLabelingPolicyNone];
    [yAxis setLabelTextStyle:textStyle];
    [yAxis setAxisLineStyle:lineStyle];
    [yAxis setMajorTickLineStyle:lineStyle];
//    yAxis.labelOffset = -3;
    yAxis.axisLabels = [NSSet setWithArray:[self calculateRangeLabels:plotData yAxis:yAxis]];
    
    [graph addPlot:self.plot toPlotSpace:graph.defaultPlotSpace];
    
    
}

- (CPTPlotRange *)yRange
{
    NSArray *values = [self.plotData allValues];
    int max = 0;
    for (NSNumber *num in values) {
        int number = [num intValue];
        if (number > max) {
            max = number;
        }
    }
    if (max < 5) {
        max = 5;
    } else if (max < 10) {
        max = 10;

    } else if (max < 20) {
        max = 20;
    } else if (max < 50) {
        max = 50;
    } else if (max < 100) {
        max = 100;
    }

    return [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(max)];
}

- (NSArray *)calculateRangeLabels:(NSDictionary *)data yAxis:(CPTAxis *)y
{
    NSArray *values = [data allValues];
    long max = 0;
    for (NSNumber *num in values) {
        long number = [num intValue];
        if (number > max) {
            max = number;
        }
    }
    long inc = 0;
    if (max < 5) {
        max = 5;
        inc = 1;
    } else if (max < 10) {
        max = 10;
        inc = 1;
    } else if (max < 20) {
        max = 20;
        inc = 5;
    } else if (max < 50) {
        max = 50;
        inc = 10;
    } else if (max < 100) {
        max = 100;
        inc = 20;
    } else {
        inc = 50;
    }
    NSMutableArray *customLabels = [NSMutableArray array];
    for (long i = 0; i < (max + inc); i += inc) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [NSString stringWithFormat:@"%lu", i]  textStyle:y.labelTextStyle];
        newLabel.tickLocation = CPTDecimalFromLong((int32_t)i);
        newLabel.offset = y.labelOffset + y.majorTickLength;
        [customLabels addObject:newLabel];
    }
    return [customLabels copy];
}



#pragma mark Bar Plot Data Source
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger count = 0;
    if (self.plotData) {
        count = [self.plotData allKeys].count > 3?3:self.plotData.count;
    }
//    NSLog(@"%lu", (unsigned long)count);
    return 3;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    long x = idx + 1;
    long y = [[self.plotData valueForKey:[self.keys objectAtIndex:idx]] longValue];
    long value;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            value = x;
            break;
            
        default:
            value = y;
            break;
    }
    NSLog(@"%lu", value);
    return [NSNumber numberWithLong:value];
}

- (CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)idx
{
    CPTColor *color = [CPTColor colorWithComponentRed:5.f/255.f green:194.f/255.f blue:240.f/255.f alpha:1.f];
    return [CPTFill fillWithColor:color];
}


@end
