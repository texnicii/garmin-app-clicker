import Toybox.Lang;
import Toybox.System;

// Centralized device-capability checks so the view and the delegate agree on
// which reset gesture is active.
module Capabilities {

    // True for touch watches that have no left-hand button (no UP key), e.g.
    // venu3 / vivoactive6. On these we reset with a long press on the screen
    // instead of pointing the user at a physical button that doesn't exist.
    function usesTouchReset() as Boolean {
        var settings = System.getDeviceSettings();

        var isTouch = false;
        if (settings has :isTouchScreen) {
            isTouch = settings.isTouchScreen;
        }
        if (!isTouch) {
            return false;
        }

        // If we can read the button set, treat "no UP button" as the signal.
        if (settings has :inputButtons) {
            var buttons = settings.inputButtons;
            if (buttons != null) {
                return (buttons & System.BUTTON_INPUT_UP) == 0;
            }
        }

        // Touch device but button info unavailable: prefer the touch gesture,
        // which always works on a touchscreen.
        return true;
    }
}
