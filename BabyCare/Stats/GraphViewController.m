//
//  GraphViewController.m
//  BabyCare
//
//  Created by Chuang HsuanChih on 7/15/15.
//  Copyright (c) 2015 Hsuan-Chih Chuang. All rights reserved.
//

#import "GraphViewController.h"

@interface GraphViewController ()
@property (nonatomic, assign) GraphType graphType;
@property (nonatomic, strong) CPTGraphHostingView *graphHostingView;
@property (nonatomic, strong) CPTXYAxisSet *axisSet;
@property (nonatomic, strong) CPTMutableLineStyle *xAxisLineStyle, *yAxisLineStyle;
@property (nonatomic, strong) CPTMutableTextStyle *xAxisTextStyle, *yAxisTextStyle, *titleTextStyle;
@property (nonatomic, strong) CPTMutableLineStyle *plotLineStyle;
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic, strong) CPTScatterPlot *plot;
@property (nonatomic, strong) UIColor *graphColor;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *nominalSectorFill, *nominalSectorText;
@property (nonatomic, strong) NSNumber *lastValid;
@end

@implementation GraphViewController

- (id)initWithGraphType:(GraphType)graphType
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.graphType = graphType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    self.graphHostingView.autoresizesSubviews = NO;
    self.graphHostingView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.graphHostingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot.identifier isEqual:@"mainplot"] )
    {
        return [self.graphData count];
    } else {
        return 0;
    }
}

// Delegate method that returns a single X or Y value for a given plot.
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ( [plot.identifier isEqual:@"mainplot"] )
    {
        NSDictionary *dataPoint = [self.graphData objectAtIndex:index];
        
        NSTimeInterval x = [dataPoint[@"time"] doubleValue];
        CGFloat y = [dataPoint[@"value"] floatValue];
        
        if ( fieldEnum == CPTScatterPlotFieldX )
        {
            return [NSNumber numberWithDouble:x];
        }
        else
        {
            if ( y > 0 && y < 255 )
            {
                if ( self.graphType == GraphTypeNominal )
                {
                    self.lastValid = [NSNumber numberWithFloat:(y-0.5)];
                }
                else
                {
                    self.lastValid = [NSNumber numberWithFloat:y];
                }
            }
            return self.lastValid;
        }
        
    }
    return nil;
}



#pragma mark - CPTScatterPlot data source
-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)idx
{
    return self.plotSymbol;
}



#pragma mark - Private utility methods

- (CPTFill*) bandFill:(BOOL)isLowerBand
{
    CPTGradient *gradient;
    if ( isLowerBand == YES )
    {
        gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:203/255.0 green:58/255.0 blue:89/255.0 alpha:0.0]
                                               endingColor:[CPTColor colorWithComponentRed:203/255.0 green:58/255.0 blue:89/255.0 alpha:0.15]];
    }
    else
    {
        gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:203/255.0 green:58/255.0 blue:89/255.0 alpha:0.15]
                                               endingColor:[CPTColor colorWithComponentRed:203/255.0 green:58/255.0 blue:89/255.0 alpha:0.0]];
    }
    gradient.angle = 90.0;
    return [CPTFill fillWithGradient:gradient];
}



#pragma mark - Public methods
- (void) reloadPlotData
{
    [self.plot reloadData];
}

- (void) launchPlot
{
    [self.graph addPlot:self.plot];
}

- (void) setNormalRange:(FPRange)range
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)self.graph.axisSet;
    for ( CPTLimitBand *limitBand in axisSet.yAxis.backgroundLimitBands )
    {
        [axisSet.yAxis removeBackgroundLimitBand:limitBand];
    }
    
    CPTPlotRange
    *lowerBandRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(self.yRange.location)
                                                   length:CPTDecimalFromDouble(range.location-self.yRange.location)],
    *upperBandRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(FPMaxRange(range))
                                                   length:CPTDecimalFromDouble(NSMaxRange(self.yRange)-FPMaxRange(range))];
    
    [axisSet.yAxis addBackgroundLimitBand:[CPTLimitBand limitBandWithRange:lowerBandRange fill:[self bandFill:YES]]];
    [axisSet.yAxis addBackgroundLimitBand:[CPTLimitBand limitBandWithRange:upperBandRange fill:[self bandFill:NO]]];
    
}

- (void) setSectorRanges
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)self.graph.axisSet;
    
    for ( CPTLimitBand *limitBand in axisSet.yAxis.backgroundLimitBands ) {
        [axisSet.yAxis removeBackgroundLimitBand:limitBand];
    }
    
    
    for (NSUInteger i = 0; i < self.nominalSectorFill.count; i++)
    {
        CPTLimitBand *limitBand =
        [CPTLimitBand limitBandWithRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(i)
                                                                      length:CPTDecimalFromDouble(1)]
                                    fill:[self.nominalSectorFill objectAtIndex:i]];
        [axisSet.yAxis addBackgroundLimitBand:limitBand];
    }
}


#pragma mark - Property accessor mthods
/*
 * Public
 */
- (void) setGraphTitle:(NSString *)graphTitle
{
    NSUInteger title = [graphTitle integerValue];
    if ( title )
    {
        self.graph.titleTextStyle = self.titleTextStyle;
        self.graph.titleDisplacement = CGPointMake(0, -3);
    }
}

- (NSString*) graphTitle
{
    return self.graph.title;
}

- (void) setLineColor:(UIColor *)lineColor
{
    self.plotLineStyle.lineColor = [CPTColor colorWithCGColor:[lineColor CGColor]];
}

- (UIColor*) lineColor
{
    return [self.plotLineStyle.lineColor uiColor];
}

- (void) setGraphData:(NSArray *)graphData
{
    _graphData = [NSArray arrayWithArray:graphData];
}

- (void) setXRange:(NSRange)xRange
{
    _xRange = NSMakeRange(xRange.location - 60*60*36, xRange.length + 60*60*36 + 60*60*12);
    
    /*
     *  setVisibleAxisRangeForPlotRange
     */
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)self.graph.axisSet;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(_xRange.location);
    axisSet.xAxis.visibleAxisRange =
    [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(_xRange.location)
                                 length:CPTDecimalFromFloat(_xRange.length)];
    
    /*
     *  setPlotSpaceRangeForPlotRange
     */
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)self.graph.defaultPlotSpace;
    plotSpace.xRange =
    [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(_xRange.location)
                                 length:CPTDecimalFromFloat(_xRange.length)];
    
    /*
     *  setupAxisForPlotRange
     */
    /*
     *  Common axis settings
     */
    axisSet.xAxis.titleTextStyle        = axisSet.yAxis.titleTextStyle        = self.titleTextStyle;
    axisSet.xAxis.minorTicksPerInterval = axisSet.yAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.minorTickLength       = axisSet.yAxis.minorTickLength       = 0.0f;
    
    /*
     *  Axis specific settings
     */
    axisSet.xAxis.axisLineStyle       = axisSet.xAxis.majorTickLineStyle = axisSet.xAxis.minorTickLineStyle = self.xAxisLineStyle;
    axisSet.xAxis.title               = self.xTitle;
    axisSet.xAxis.titleOffset         = 4.0f;
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    axisSet.xAxis.majorTickLength = 0.0f;
    
    CGFloat labelOffset;
    if (self.graphType == GraphTypeNumeric)
    {
        labelOffset = 4.0f;
    }
    else
    {
        labelOffset = -20.0f;
    }
    
    NSMutableArray *tickLocations = [NSMutableArray arrayWithCapacity:7];
    NSMutableArray *labels = [NSMutableArray arrayWithCapacity:7];
    for ( NSUInteger i = 0; i < 7; i++ )
    {
        NSTimeInterval labelPoint = xRange.location + i*(60*60*24);
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[self.dateFormatter stringFromDate:
                                                                  [NSDate dateWithTimeIntervalSince1970:labelPoint+(60*60*24)]]
                                                       textStyle:self.xAxisTextStyle];
        label.tickLocation = CPTDecimalFromDouble(labelPoint);
        label.offset = labelOffset;
        [tickLocations addObject:[NSNumber numberWithDouble:(labelPoint)]];
        [labels addObject:label];
    }
    axisSet.xAxis.majorTickLocations = [NSSet setWithArray:tickLocations];
    axisSet.xAxis.axisLabels = [NSSet setWithArray:labels];
    
}

- (void) setYRange:(NSRange)yRange
{
    _yRange = yRange;
    
    /*
     *  set VisibleAxisRange
     */
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)self.graph.axisSet;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(_yRange.location);
    axisSet.yAxis.visibleAxisRange =
    [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(_yRange.location)
                                 length:CPTDecimalFromFloat(_yRange.length)];
    
    /*
     *  set visibleRange
     */
    axisSet.yAxis.visibleRange =
    [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(_yRange.location)
                                 length:CPTDecimalFromFloat(_yRange.length)];
    
    /*
     *  set plotSpaceRange
     */
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)self.graph.defaultPlotSpace;
    plotSpace.yRange =
    [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(_yRange.location)
                                 length:CPTDecimalFromFloat(_yRange.length)];
    
    /*
     *  setup AxisForPlotRange
     */
    axisSet.yAxis.axisLineStyle       = axisSet.yAxis.majorTickLineStyle = axisSet.yAxis.minorTickLineStyle = self.yAxisLineStyle;
    axisSet.yAxis.title               = self.yTitle;
    axisSet.yAxis.labelTextStyle      = self.yAxisTextStyle;
    axisSet.yAxis.majorGridLineStyle  = self.yAxisLineStyle;
    
    if (self.graphType != GraphTypeNominal)
    {
        axisSet.yAxis.labelOffset         = -35.0f;
        axisSet.yAxis.majorTickLength     = 0.0f;
        axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(self.yAxisInterval);
        axisSet.yAxis.labelFormatter = self.numberFormatter;
        axisSet.yAxis.labelAlignment = CPTAlignmentBottom;
    }
    else
    {
        axisSet.yAxis.majorTickLength     = 0.0f;
        
        axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
        NSUInteger maxRange = NSMaxRange(_yRange);
        NSMutableArray *tickLocations = [NSMutableArray arrayWithCapacity:maxRange];
        NSMutableArray *labels = [NSMutableArray arrayWithCapacity:maxRange];
        for ( NSUInteger i = 0; i < maxRange; i++ )
        {
            NSTimeInterval labelPoint = _yRange.location + i+0.5;
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[self.nominalSectorText objectAtIndex:i]
                                                           textStyle:self.yAxisTextStyle];
            label.tickLocation = CPTDecimalFromDouble(labelPoint);
            label.offset = -35.0f;
            label.alignment = CPTAlignmentCenter;
            [tickLocations addObject:[NSNumber numberWithDouble:(labelPoint-0.5)]];
            [labels addObject:label];
        }
        axisSet.yAxis.majorTickLocations = [NSSet setWithArray:tickLocations];
        axisSet.yAxis.axisLabels = [NSSet setWithArray:labels];
    }
    
}


/*
 *  Private
 */
- (CPTScatterPlot*) plot
{
    if (!_plot)
    {
        _plot = [[CPTScatterPlot alloc] init];
        _plot.dataSource = self;
        _plot.delegate = self;
        _plot.identifier = @"mainplot";
        _plot.dataLineStyle = self.plotLineStyle;
        if (self.graphType == GraphTypeNominal)
        {
            _plot.borderWidth = 0.0f;
        }
    }
    return _plot;
}

-(CPTXYGraph*) graph
{
    if (!_graph)
    {
        _graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds];
        _graph.paddingLeft = 0.0f;
        _graph.paddingTop = 0.0f;
        _graph.paddingRight = 0.0f;
        _graph.paddingBottom = 0.0f;
        _graph.plotAreaFrame.paddingLeft = 0.0f;
        _graph.plotAreaFrame.paddingRight = 0.0f;
        _graph.borderWidth = 0.0f;
        _graph.plotAreaFrame.borderWidth = 0.0f;
        
        if (self.graphType != GraphTypeNominal)
        {
            _graph.plotAreaFrame.paddingTop = 35.0f;
            _graph.plotAreaFrame.paddingBottom = 25.0f;
        }
        else
        {
            _graph.plotAreaFrame.paddingTop = 0.0f;
            _graph.plotAreaFrame.paddingBottom = 0.0f;
        }
    }
    return _graph;
}

- (CPTGraphHostingView*) graphHostingView
{
    if (!_graphHostingView)
    {
        _graphHostingView = [[CPTGraphHostingView alloc] initWithFrame:self.view.frame];
        _graphHostingView.hostedGraph = self.graph;
    }
    return _graphHostingView;
}


-(CPTPlotSymbol*) plotSymbol {
    
    if (_plotSymbol == nil) {
        _plotSymbol = [CPTPlotSymbol plotSymbol];
        _plotSymbol.lineStyle = self.plotLineStyle;
        _plotSymbol.size = CGSizeMake(8.0, 8.0);
    }
    return _plotSymbol;
}


-(CPTLineStyle*) plotLineStyle
{
    if (!_plotLineStyle)
    {
        _plotLineStyle = [CPTMutableLineStyle lineStyle];
        _plotLineStyle.lineColor = [CPTColor darkGrayColor];
        _plotLineStyle.lineWidth = 2.0;
    }
    return _plotLineStyle;
}

-(CPTMutableLineStyle*) xAxisLineStyle
{
    if (!_xAxisLineStyle)
    {
        _xAxisLineStyle = [CPTMutableLineStyle lineStyle];
        _xAxisLineStyle.lineColor = [CPTColor colorWithComponentRed:220/255.0 green:217/255.0 blue:224/255.0 alpha:1.0];
        _xAxisLineStyle.lineWidth = 0.0;
    }
    return _xAxisLineStyle;
}

-(CPTMutableLineStyle*) yAxisLineStyle
{
    if (!_yAxisLineStyle)
    {
        _yAxisLineStyle = [CPTMutableLineStyle lineStyle];
        _yAxisLineStyle.lineColor = [CPTColor colorWithComponentRed:220/255.0 green:217/255.0 blue:224/255.0 alpha:1.0];
    }
    return _yAxisLineStyle;
}

-(CPTMutableTextStyle*) xAxisTextStyle
{
    if (!_xAxisTextStyle)
    {
        _xAxisTextStyle = [CPTMutableTextStyle textStyle];
        _xAxisTextStyle.fontName = @"Helvetica-Bold";
        _xAxisTextStyle.fontSize = 12.0;
    }
    return _xAxisTextStyle;
}

-(CPTMutableTextStyle*) yAxisTextStyle
{
    if (!_yAxisTextStyle)
    {
        _yAxisTextStyle = [CPTMutableTextStyle textStyle];
        _yAxisTextStyle.fontName = @"Helvetica-Bold";
        _yAxisTextStyle.fontSize = 12.0;
    }
    return _yAxisTextStyle;
}

-(CPTMutableTextStyle*) titleTextStyle
{
    if (!_titleTextStyle)
    {
        _titleTextStyle = [CPTMutableTextStyle textStyle];
        _titleTextStyle.fontName = @"Helvetica-Bold";
        _titleTextStyle.fontSize = 12.0;
        if (self.graphType != GraphTypeNominal)
        {
            _titleTextStyle.color = [CPTColor darkGrayColor];
        }
        else
        {
            _titleTextStyle.color = [CPTColor whiteColor];
        }
    }
    return _titleTextStyle;
}

-(CPTXYAxisSet*) axisSet
{
    if (!_axisSet)
    {
        _axisSet = (CPTXYAxisSet*)self.graph.axisSet;
    }
    return _axisSet;
}

- (NSNumberFormatter*) numberFormatter
{
    if (!_numberFormatter)
    {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        [_numberFormatter setGeneratesDecimalNumbers:NO];
        [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return _numberFormatter;
}

- (NSDateFormatter*) dateFormatter
{
    if (!_dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"d"];
    }
    return _dateFormatter;
}

- (UIColor*) graphColor
{
    return [UIColor colorWithRed:(249/255.0)
                           green:(248/255.0)
                            blue:(249/255.0)
                           alpha:1.0];
}


- (NSArray*) nominalSectorFill
{
    if (!_nominalSectorFill)
    {
        
        _nominalSectorFill = @[
                               [CPTFill fillWithColor:[CPTColor colorWithComponentRed:180/255.0
                                                                                green:217/255.0
                                                                                 blue:253/255.0
                                                                                alpha:1.0]],
                               [CPTFill fillWithColor:[CPTColor colorWithComponentRed:121/255.0
                                                                                green:187/255.0
                                                                                 blue:252/255.0
                                                                                alpha:1.0]],
                               [CPTFill fillWithColor:[CPTColor colorWithComponentRed:77/255.0
                                                                                green:153/255.0
                                                                                 blue:230/255.0
                                                                                alpha:1.0]],
                               [CPTFill fillWithColor:[CPTColor colorWithComponentRed:41/255.0
                                                                                green:109/255.0
                                                                                 blue:180/255.0
                                                                                alpha:1.0]]
                               ];
    }
    return _nominalSectorFill;
}

- (NSArray*) nominalSectorText
{
    if (!_nominalSectorText)
    {
        _nominalSectorText = @[@"1", @"2", @"3", @"4"];
    }
    return _nominalSectorText;
}

@end
