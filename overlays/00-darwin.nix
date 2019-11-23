self: super:

{
#  darwin = super.darwin // {
#    apple_sdk = super.darwin.apple_sdk // {
#      sdk = super.darwin.apple_sdk.sdk.overrideAttrs (_: {
#        version = "10.13";
#        src = super.fetchurl {
#          url    = "http://swcdn.apple.com/content/downloads/50/15/041-91747-A_WICZE7RNVZ/rayjnqf847xflt3tan8o8agod67eq88cav/DevSDK_macOS1013_Public.pkg";
#          sha256 = "1dl1ypxh9l5xp9h2cyv332apawbxxgc2bbkk6223958f1kdak4d6";
#        };
#      });
#    };
#  };
}
