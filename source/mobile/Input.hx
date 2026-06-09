package mobile;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.input.touch.FlxTouch;
import mobile.controls.menus.VirtualPad;

#if mobile
class Input extends FlxBasic {
    public var isInputEnabled(get, set):Bool;
    
    private var _enabled:Bool = true;
    private var trackedTouchID:Int = -1;
    private var wasVirtualPadTouching:Bool = false;

    private var lastTouchX:Float = 0.0;
    private var lastTouchY:Float = 0.0;
    private var lastTouchScreenX:Float = 0.0;
    private var lastTouchScreenY:Float = 0.0;

    public function new() {
        super();
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
        
        processMouseStateTransitions();

        if (activeTouch != null) {
            updateTouchCoordinates(activeTouch);
            applyTouchToMouseState(activeTouch);
        } else {
            invalidateTrackedTouch();
        }

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
        if (!wasVirtualPadTouching) {
            @:privateAccess {
                var currentState:Int = FlxG.mouse._leftButton.current;
                if (currentState == 1 || currentState == 2) {
                    FlxG.mouse._leftButton.current = -1;
                } else {
                    FlxG.mouse._leftButton.current = 0;
                }
            }
            trackedTouchID = -1;
            wasVirtualPadTouching = true;
        } else {
            @:privateAccess FlxG.mouse._leftButton.current = 0;
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

    private function processMouseStateTransitions():Void {
        @:privateAccess {
            var state:Int = FlxG.mouse._leftButton.current;
            if (state == -1) {
                FlxG.mouse._leftButton.current = 0;
            } else if (state == 2) {
                FlxG.mouse._leftButton.current = 1;
            }
        }
    }

    private function updateTouchCoordinates(touch:FlxTouch):Void {
        lastTouchX = touch.x;
        lastTouchY = touch.y;
        lastTouchScreenX = touch.screenX;
        lastTouchScreenY = touch.screenY;

        FlxG.mouse.x = Std.int(lastTouchX);
        FlxG.mouse.y = Std.int(lastTouchY);
        FlxG.mouse.screenX = Std.int(lastTouchScreenX);
        FlxG.mouse.screenY = Std.int(lastTouchScreenY);
    }

    private function applyTouchToMouseState(touch:FlxTouch):Void {
        @:privateAccess {
            if (touch.justPressed) {
                FlxG.mouse._leftButton.current = 2;
            } 
            else if (touch.justReleased) {
                FlxG.mouse._leftButton.current = -1;
                trackedTouchID = -1;
            }
            else if (touch.pressed) {
                FlxG.mouse._leftButton.current = 1;
            }
        }
    }

    private function invalidateTrackedTouch():Void {
        trackedTouchID = -1;
    }

    override public function destroy():Void {
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
