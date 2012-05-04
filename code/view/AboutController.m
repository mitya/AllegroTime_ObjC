#import "AboutController.h"

@implementation AboutController

@synthesize webView;

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"О программе";
  self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  self.webView.backgroundColor = [UIColor yellowColor];
  self.webView.delegate = self;
  [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"data/about" ofType:@"html"];
  NSString *htmlString = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:NULL];
  [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"/"]];
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
  }
  return YES;
}


@end
