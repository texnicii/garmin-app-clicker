import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ClickerDelegate extends WatchUi.BehaviorDelegate {

    private var _view as ClickerView;

    function initialize(view as ClickerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Main button (START/SELECT) — count +1.
    function onSelect() as Boolean {
        bump();
        return true;
    }

    // Touchscreen tap anywhere — count +1.
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        bump();
        return true;
    }

    // Long-press of the menu/up button — ask before resetting.
    function onMenu() as Boolean {
        promptReset();
        return true;
    }

    // Long-press on the touchscreen. On touch watches without a left button
    // (venu3 / vivoactive6) this is the reset gesture. On watches that have the
    // menu button we let onMenu handle it, so we don't double-trigger.
    function onHold(evt as WatchUi.ClickEvent) as Boolean {
        if (Capabilities.usesTouchReset()) {
            promptReset();
            return true;
        }
        return false;
    }

    private function bump() as Void {
        _view.increment();
        playClick();
        vibrate();
    }

    private function promptReset() as Void {
        var dialog = new WatchUi.Confirmation(
            WatchUi.loadResource(Rez.Strings.ResetPrompt) as String
        );
        WatchUi.pushView(
            dialog,
            new ResetConfirmationDelegate(_view),
            WatchUi.SLIDE_IMMEDIATE
        );
    }

    private function playClick() as Void {
        if ((Toybox has :Attention) && (Attention has :playTone)) {
            Attention.playTone(Attention.TONE_KEY);
        }
    }

    private function vibrate() as Void {
        if ((Toybox has :Attention) && (Attention has :vibrate)) {
            var settings = System.getDeviceSettings();
            // Respect the user's vibration setting when it is exposed.
            if ((settings has :vibrateOn) && !settings.vibrateOn) {
                return;
            }
            Attention.vibrate([ new Attention.VibeProfile(50, 60) ]);
        }
    }
}

class ResetConfirmationDelegate extends WatchUi.ConfirmationDelegate {

    private var _view as ClickerView;

    function initialize(view as ClickerView) {
        ConfirmationDelegate.initialize();
        _view = view;
    }

    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            _view.reset();
        }
        return true;
    }
}
