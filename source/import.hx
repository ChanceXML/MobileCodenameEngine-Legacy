#if (android && !macro)
import extension.androidtools.Tools as AndroidTools;
import extension.androidtools.Settings as AndroidSettings;
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.callback.CallBack as AndroidCallBack;
import extension.androidtools.content.Context as AndroidContext;
import extension.androidtools.jni.JNICache as JNICache;
import extension.androidtools.jni.JNIUtil as JNIUtil;
import extension.androidtools.media.AudioManager as AndroidAudioManager;
import extension.androidtools.os.Build as AndroidBuild;
import extension.androidtools.os.Build.VERSION as AndroidVersions;
import extension.androidtools.os.Build.VERSION_CODES as AndroidVersionsCodes;
import extension.androidtools.os.Environment as AndroidEnvironment;
import extension.androidtools.widget.Toast as AndroidToast;
#elseif ios
import iostools.IOSTools as IOSTools;
import iostools.Device.DeviceManager as IOSDeviceManager;
import iostools.Files.FilePermissionManager as IOSPermissions;
import iostools.Files.FilePickerManager as IOSFilePicker;
import iostools.Permissions.PermissionManager as IOSPermissionManager;
import iostools.Permissions.PermissionType as IOSPermissionType;
import iostools.Storage.StorageManager as IOSStorageManager;
import iostools.UI.AlertManager as IOSAlert;
import iostools.UI.FeedbackManager as IOSFeedback;
#else
//
//
#end
#if mobile
import mobile.controls.game.*;
import mobile.controls.menus.*;
import mobile.utils.*;
#end
