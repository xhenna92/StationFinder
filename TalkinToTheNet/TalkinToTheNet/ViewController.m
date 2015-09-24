//
//  ViewController.m
//  TalkinToTheNet
//
//  Created by Henna on 9/24/15.
//  Copyright (c) 2015 Henna. All rights reserved.
//

#import "ViewController.h"
#import "APIManager.h"
#import "place.h"
#import "placeDetailViewController.h"


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITextField *searchLocationTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *places;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.searchLocationTextField setDelegate:self];

}

- (void) makeFSAPIRequestWithSearchTerm:(NSString*) searchTerm andLocation:(NSString*) location callbackBlock:(void(^)())block{
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?near=%@&query=%@&client_id=V4EZD2DVUA5S4EW4UWUFJQRCRO3L0QEBRZ2MNOA2IAVF2VXY&client_secret=J1KFSATHO1PDRRLDSQCEBSZ0ULLBVK20YC1WYIN3T53LXXPX&v=20150924", location, searchTerm];
    
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL   URLWithString:encodedString];
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.places = [[NSMutableArray alloc]init];
            
            NSArray *results = [[json objectForKey:@"response"] objectForKey:@"venues"];

            
            for (NSDictionary *result in results) {
                place *obj = [[place alloc]init];
                obj.name = [result objectForKey:@"name"];
                NSString *address = [[result objectForKey:@"location"] objectForKey:@"address"];
                NSString *city = [[result objectForKey:@"location"] objectForKey:@"city"];
                NSString *state = [[result objectForKey:@"location"] objectForKey:@"state"];
                NSString *postalCode = [[result objectForKey:@"location"] objectForKey:@"postalCode"];
                
                obj.address = [NSString stringWithFormat:@"%@ %@, %@ %@", address, city, state, postalCode];
                NSString *latitude = [[[result objectForKey:@"location"] objectForKey:@"lat"] stringValue];
                NSString *longitude = [[[result objectForKey:@"location"] objectForKey:@"lng"] stringValue];
                obj.checkIns = [[[result objectForKey:@"stats"] objectForKey:@"checkinsCount"] stringValue];

                obj.latlng = [latitude stringByAppendingString:[NSString stringWithFormat:@",%@", longitude]];

                [self.places addObject:obj];
            }
            block();
        }
        
    }];
    
}

# pragma mark -tableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.places.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    place * result = [self.places objectAtIndex:indexPath.row];
    
//    NSURL *imgURL = [NSURL URLWithString:result.imgURL];
//    NSData *imageData = [NSData dataWithContentsOfURL:imgURL];
//    UIImage *imageToDisplay = [UIImage imageWithData:imageData];
    
    cell.textLabel.text = result.name;
    cell.detailTextLabel.text = result.address;
    
//    cell.detailTextLabel.text = result.author;
//    cell.imageView.image = imageToDisplay;
    return cell;
}

# pragma mark - text field delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    
    NSString * query = self.searchTextField.text;
    
    [self makeFSAPIRequestWithSearchTerm:query andLocation:textField.text callbackBlock:^{

        [self.tableView reloadData];
    }];
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    placeDetailViewController *viewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"placeDetailVCIdentifier"];
    viewController.fourSquareObject = [self.places objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
