
#import "sc_GradientButton.h"
@interface sc_GradientButton()
@end

@implementation sc_GradientButton

//--------------------------------------------------------------------------------------------------------
// setButtonWithStyle
//--------------------------------------------------------------------------------------------------------
-(void)setButtonWithStyle: (CustomButtonType) customButtonType {
    
    NSString *normalImageName;
    NSString *highlightedlImageName;
    UIColor *nornalTitleColor;
    UIColor *highlightedTitleColor;
    
    switch (customButtonType) {
        case (CUSTOMBUTTONTYPE_NORMAL):
            normalImageName = @"greyButton.png";
            highlightedlImageName = @"blueButtonHighlight.png";
            nornalTitleColor = [UIColor blackColor];
            highlightedTitleColor = [UIColor whiteColor];
            break;
        case (CUSTOMBUTTONTYPE_DANGEROUS):
            normalImageName = @"orangeButton.png";
            highlightedlImageName = @"orangeButtonHighlight.png";
            nornalTitleColor = [UIColor whiteColor];
            highlightedTitleColor = [UIColor whiteColor];
            break;
        case (CUSTOMBUTTONTYPE_IMPORTANT):
            normalImageName = @"blueButton.png";
            highlightedlImageName = @"blueButtonHighlight.png";
            nornalTitleColor = [UIColor whiteColor];
            highlightedTitleColor = [UIColor whiteColor];
            break;
        case (CUSTOMBUTTONTYPE_TRANSPARENT):
            normalImageName = @"transparentButton.png";
            highlightedlImageName = @"transparentButtonHighlight.png";
            nornalTitleColor = [UIColor whiteColor];
            highlightedTitleColor = [UIColor whiteColor];
            break;
        case (CUSTOMBUTTONTYPE_LIGHT):
            normalImageName = @"whiteButton.png";
            highlightedlImageName = @"blueButtonHighlight.png";
            nornalTitleColor = [UIColor blackColor];
            highlightedTitleColor = [UIColor blackColor];
            break;
        default:
            normalImageName = @"greyButton.png";
            highlightedlImageName = @"greyButtonHighlight.png";
            nornalTitleColor = [UIColor blackColor];
            highlightedTitleColor = [UIColor blackColor];
            break;
    }
    
    [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self setTitleColor:nornalTitleColor forState:UIControlStateNormal];
    [self setTitleColor:highlightedTitleColor forState:UIControlStateHighlighted];
    
    UIImage *buttonImage = [[UIImage imageNamed:normalImageName]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:highlightedlImageName]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    [self setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}


@end
