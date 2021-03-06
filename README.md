# quillview

Display quill format on iOS native views.

# Installtion

```bash
vi Podfile
```
```text
platform :ios, '8.0'

target 'your_target_name' do
    pod 'QuillView', :git => 'https://github.com/hivecms/QuillView.git'
end
```
```bash
pod install
```


# Usage

```objc

#import "QuillView.h"

...

QuillView *quillView = [[QuillView alloc] initWithFrame:frame];
quillView.contentStrings = @"{\"ops\":[{\"insert\":\"Quill uses classes for most inline styles.\\n\\nThe exception is \"},{\"attributes\":{\"background\":\"yellow\"},\"insert\":\"background\"},{\"insert\":\" and \"},{\"attributes\":{\"color\":\"purple\"},\"insert\":\"color\"},{\"insert\":\",\\nwhere it uses inline styles.\\n\\nThis \"},{\"attributes\":{\"font\":\"PingFang TC\",\"strike\":\"true\"},\"insert\":\"demo\"},{\"insert\":\" shows how to \"},{\"attributes\":{\"size\":\"32px\"},\"insert\":{\"formula\":\"change\"}},{\"insert\":\" this.\\n\"}]}";
[self.view addSubView: QuillView];

```
![](http://7xpvul.com1.z0.glb.clouddn.com/4370C781-CDEA-44E0-A5F1-1520601B7962.png)


# Ref

Quill Editor
https://quilljs.com/
https://github.com/quilljs/quill

CSS Parser
https://github.com/gavinkwoe/BeeFramework/tree/master/framework/mvc/view/css
