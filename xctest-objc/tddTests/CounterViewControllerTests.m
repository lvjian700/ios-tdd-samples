#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import "CounterViewController.h"
#import "Counter.h"


@interface CounterViewControllerTests : XCTestCase

@end

@implementation CounterViewControllerTests {
    CounterViewController *_sut;
    Counter *_mockCounter;
}

- (void)setUp {
    [super setUp];
    _mockCounter = MKTMock([Counter class]);
    _sut = [self findController:@"counterViewController"];
    _sut.counter = _mockCounter;
    [_sut view];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_load_controller_from_storyboard_should_with_default_counter {
    CounterViewController *controller = [self findController:@"counterViewController"];
    [controller view];
    HC_assertThat(controller.counter, HC_is(HC_notNilValue()));
}

- (void)test_increment_should_ask_counter_to_increment {
    [_sut incrementCounter:nil];

    [MKTVerify(_mockCounter) increment];
}

- (void)test_decrement_should_ask_counter_to_decrement {
    [_sut decrementCounter:nil];

    [MKTVerify(_mockCounter) decrement];
}

- (void)test_model_changed_notification_should_update_counter_label {
    [MKTGiven([_mockCounter count]) willReturnInteger:2];

    [[NSNotificationCenter defaultCenter] postNotificationName:CounterModelChanged object:_mockCounter];
    HC_assertThat(_sut.counterLabel.text, HC_is(HC_equalTo(@"2")));
}

- (void)test_model_changed_notification_from_different_model_should_not_update_counter_label {

    [MKTGiven([_mockCounter count]) willReturnInteger:22];
    Counter *differentCounter = [[Counter alloc] init];
    differentCounter.count = 2;

    [[NSNotificationCenter defaultCenter] postNotificationName:CounterModelChanged object:differentCounter];

    HC_assertThat(_sut.counterLabel.text, HC_is(HC_equalTo(@"0")));
}



- (void)test_counter_label_should_be_connected {
    HC_assertThat(_sut.counterLabel, HC_is(HC_notNilValue()));
}

- (void)test_counter_label_default_text_should_be_zero {
    HC_assertThat(_sut.counterLabel.text, HC_is(@"0"));
}

- (void)test_counter_label_with_zero_should_be_black {
    [_sut updateCounterLabel: 0];
    HC_assertThat(_sut.counterLabel.textColor, HC_is([UIColor blackColor]));
}

- (void)test_counter_label_with_positive_should_be_green {
    [_sut updateCounterLabel: 1];
    HC_assertThat(_sut.counterLabel.textColor, HC_is([UIColor greenColor]));
}

- (void)test_counter_label_with_negative_should_be_red {
    [_sut updateCounterLabel: -1];
    HC_assertThat(_sut.counterLabel.textColor, HC_is([UIColor redColor]));
}

- (void)test_plus_button_should_be_connected {
    HC_assertThat(_sut.plusButton, HC_is(HC_notNilValue()));
}

- (void)test_plus_button_should_observe_action {
    HC_assertThat([_sut.plusButton actionsForTarget:_sut forControlEvent:UIControlEventTouchUpInside],
            HC_contains(@"incrementCounter:", nil));
}

- (void)test_minus_button_should_be_connected {
    HC_assertThat(_sut.minusButton, HC_is(HC_notNilValue()));
}

- (void)test_minus_button_action {
    HC_assertThat([_sut.minusButton actionsForTarget:_sut forControlEvent:UIControlEventTouchUpInside],
            HC_contains(@"decrementCounter:", nil));
}

- (CounterViewController *)findController:(NSString *)controllerId {
    return [self findController:controllerId inStoryboard:@"Main"];
}

- (CounterViewController *)findController:(NSString *)controllerId inStoryboard:(NSString *)storyboard {
    return [[UIStoryboard storyboardWithName:storyboard bundle:[NSBundle mainBundle]]
            instantiateViewControllerWithIdentifier:controllerId];
}

@end
