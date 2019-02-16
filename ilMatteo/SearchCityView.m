//
//  SearchCityView.m
//  QUESTAELABUONA
//
//  Created by Simone Montali on 13/02/19.
//  Copyright © 2019 Simone Montali. All rights reserved.
//

#import "SearchCityView.h"
@import AutoCompletion;

@interface SearchCityView ()

@end

@implementation SearchCityView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    JSONDataSource *jsonDataSource = [[JSONDataSource alloc] init];
    _jsonTextField.suggestionsResultDataSource = jsonDataSource;
    _jsonTextField.suggestionsResultDelegate = self;
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

@end
