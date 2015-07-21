#import "tmp.js";
#import "_tmp_.js";
#import "http://crypto-js.googlecode.com/svn/tags/3.1.2/build/rollups/aes.js"

var decrypted_usr = CryptoJS.AES.decrypt(username, security);
var decrypted_pass = CryptoJS.AES.decrypt(password, security);
var final_decrypted_username = decrypted_usr.toString(CryptoJS.enc.Utf8);
var final_decrypted_password = decrypted_pass.toString(CryptoJS.enc.Utf8);

var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().textFields()[0].textFields()[0].tap();
target.frontMostApp().keyboard().typeString(final_decrypted_username);
target.frontMostApp().mainWindow().secureTextFields()[0].secureTextFields()[0].tap();
target.frontMostApp().keyboard().typeString(final_decrypted_password);
target.frontMostApp().mainWindow().buttons()["GO"].tap();

target.delay(3);

target.captureScreenWithName("myscreenshot1");

target.frontMostApp().mainWindow().scrollViews()[0].webViews()[0].tapWithOptions({tapOffset:{x:0.90, y:0.90}});

target.delay(3);

target.captureScreenWithName("myscreenshot2");

target.delay(3);

target.captureScreenWithName("myscreenshot3");
