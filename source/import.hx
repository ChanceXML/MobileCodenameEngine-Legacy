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
#else
//
//
#end
#if mobile
import mobile.controls.game.*;
import mobile.controls.menus.*;
import mobile.utils.*;
#end
