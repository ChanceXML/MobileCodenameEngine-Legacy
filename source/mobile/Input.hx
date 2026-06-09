package mobile;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.FlxBasic;
import flixel.input.touch.FlxTouch;
import flixel.input.FlxInput.FlxInputState;
import mobile.controls.menus.VirtualPad;

#if mobile
class Input extends FlxBasic {
    public var isInputEnabled(get, set):Bool;
    
    public static var holdDelay:Float = 0.25; 
    public static var clickThreshold:Float = 10.0;

    private var _enabled:Bool = true;
    private var trackedTouchID:Int = -1;
    private var wasVirtualPadTouching:Bool = false;

    private var pressTime:Float = 0.0;
    private var isPressing:Bool = false;
    private var isDragging:Bool = false;
    private var startPos:FlxPoint;

    private var simulatedState:Int = 0; 
    private var pendingTapRelease:Bool = false;

    private var lastMouseX:Int = 0;
    private var lastMouseY:Int = 0;
    private var lastScreenX:Int = 0;
    private var lastScreenY:Int = 0;

    public function new() {
        super();
        startPos = FlxPoint.get();
    }

    override public function update(elapsed:Float):Void {
        if (!_enabled || FlxG.touches == null || FlxG.mouse == null) {
            super.update(elapsed);
            return;
        }

        var isPadActive:Bool = checkVirtualPadActive();
        if (isPadActive) {
            handleVirtualPadConflict();
            super.update(elapsed);
            return;
        }

        wasVirtualPadTouching = false;
        
        var activeTouch:FlxTouch = getActiveTouchInstance();

        if (activeTouch != null) {
            processTouchInput(activeTouch, elapsed);
        } else {
            processDetachedInput(elapsed);
        }

        applySimulatedStateToMouse();

        super.update(elapsed);
    }

    private function checkVirtualPadActive():Bool {
        var isAnyFingerDown:Bool = false;
        var touchList = FlxG.touches.list;
        
        if (touchList != null) {
            var totalTouches:Int = touchList.length;
            for (i in 0...totalTouches) {
                var touch:FlxTouch = touchList[i];
                if (touch != null && touch.pressed) {
                    isAnyFingerDown = true;
                    break;
                }
            }
        }
        
        if (!isAnyFingerDown) {
            VirtualPad.touchingPad = false;
        }

        return VirtualPad.touchingPad;
    }

    private function handleVirtualPadConflict():Void {
        isPressing = false;
        isDragging = false;
        trackedTouchID = -1;
        simulatedState = 0;
        pendingTapRelease = false;

        if (!wasVirtualPadTouching) {
            @:privateAccess {
                var currentState = FlxG.mouse._leftButton.current;
                if (currentState == FlxInputState.PRESSED || currentState == FlxInputState.JUST_PRESSED) {
                    FlxG.mouse._leftButton.current = FlxInputState.JUST_RELEASED;
                } else {
                    FlxG.mouse._leftButton.current = FlxInputState.RELEASED;
                }
            }
            wasVirtualPadTouching = true;
        } else {
            @:privateAccess FlxG.mouse._leftButton.current = FlxInputState.RELEASED;
        }
    }

    private function getActiveTouchInstance():FlxTouch {
        var touchList = FlxG.touches.list;
        if (touchList == null) {
            return null;
        }

        var totalTouches:Int = touchList.length;

        if (trackedTouchID != -1) {
            for (i in 0...totalTouches) {
                var touch:FlxTouch = touchList[i];
                if (touch != null && touch.touchPointID == trackedTouchID) {
                    return touch;
                }
            }
        } else {
            for (i in 0...totalTouches) {
                var touch:FlxTouch = touchList[i];
                if (touch != null && touch.justPressed) {
                    trackedTouchID = touch.touchPointID;
                    return touch;
                }
            }
        }

        return null;
    }

    private function processTouchInput(touch:FlxTouch, elapsed:Float):Void {
        var rawJustPressed:Bool = touch.justPressed;
        var rawPressed:Bool = touch.pressed;
        var rawJustReleased:Bool = touch.justReleased;
        var tx:Float = touch.x;
        var ty:Float = touch.y;
        
        lastMouseX = Std.int(tx);
        lastMouseY = Std.int(ty);
        lastScreenX = Std.int(touch.screenX);
        lastScreenY = Std.int(touch.screenY);
        
        if (rawJustReleased) {
            trackedTouchID = -1;
        }

        if (rawJustPressed) {
            pressTime = 0.0;
            isPressing = true;
            isDragging = false;
            startPos.set(tx, ty);
        }

        if (isPressing && rawPressed) {
            pressTime += elapsed;
            
            var dx:Float = startPos.x - tx;
            var dy:Float = startPos.y - ty;
            var distance:Float = Math.sqrt((dx * dx) + (dy * dy));

            if (!isDragging && (pressTime >= holdDelay || distance >= clickThreshold)) {
                isDragging = true;
                simulatedState = 2;
            }
        }

        if (rawJustReleased && isPressing) {
            if (!isDragging) {
                simulatedState = 2;
                pendingTapRelease = true;
            } else {
                simulatedState = -1;
            }
            isPressing = false;
            isDragging = false;
        }
    }

    private function processDetachedInput(elapsed:Float):Void {
        if (isPressing) {
            if (!isDragging) {
                simulatedState = 2;
                pendingTapRelease = true;
            } else {
                simulatedState = -1;
            }
            isPressing = false;
            isDragging = false;
        }
        trackedTouchID = -1;
    }

    private function applySimulatedStateToMouse():Void {
        @:privateAccess {
            if (simulatedState == -1) {
                FlxG.mouse._leftButton.current = FlxInputState.JUST_RELEASED;
                updateMouseCoordinates();
                simulatedState = 0;
            }
            else if (simulatedState == 2) {
                FlxG.mouse._leftButton.current = FlxInputState.JUST_PRESSED;
                updateMouseCoordinates();
                
                if (pendingTapRelease) {
                    simulatedState = -1;
                    pendingTapRelease = false;
                } else {
                    simulatedState = 1;
                }
            }
            else if (simulatedState == 1) {
                if (!isDragging && !isPressing) {
                    simulatedState = 0;
                    FlxG.mouse._leftButton.current = FlxInputState.RELEASED;
                } else {
                    FlxG.mouse._leftButton.current = FlxInputState.PRESSED;
                    updateMouseCoordinates();
                }
            }
            else {
                FlxG.mouse._leftButton.current = FlxInputState.RELEASED;
            }
        }
    }

    private function updateMouseCoordinates():Void {
        @:privateAccess {
            FlxG.mouse.x = lastMouseX;
            FlxG.mouse.y = lastMouseY;
            FlxG.mouse.screenX = lastScreenX;
            FlxG.mouse.screenY = lastScreenY;
        }
    }

    override public function destroy():Void {
        startPos = FlxDestroyUtil.put(startPos);
        trackedTouchID = -1;
        wasVirtualPadTouching = false;
        super.destroy();
    }

    private function get_isInputEnabled():Bool {
        return _enabled;
    }

    private function set_isInputEnabled(value:Bool):Bool {
        return _enabled = value;
    }
}
#end
