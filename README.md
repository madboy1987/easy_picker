# easy_picker

目录选择器，目前只支持Android。

## Getting Started
AndroidManifest.xml声明权限：
```    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.MOUNT_UNMOUNT_FILESYSTEMS" />
```

**注意：** android/app/build.gradle中的targetSdkVersion、compileSdkVersion如果大于等于29，那么需要如下两种修改策略（任选一种即可）
* 修改targetSdkVersion、compileSdkVersion为28
* 修改AndroidManifest.xml中的application节点，添加属性android:requestLegacyExternalStorage="true"

pubspec.yaml添加依赖：

```
directory_picker: easy_picker^1.0.0
```

使用方式（申请权限推荐使用：permission_handler，下面的代码示例也是使用该插件）
```dart
  pick() async {
    if (await Permission.storage.request().isGranted) {
      var selectedPath = Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => DirectoryPicker(),
        ),
      );
    }
  }
```


