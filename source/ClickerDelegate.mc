import Toybox.Attention;
import Toybox.Lang;
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
        var dialog = new WatchUi.Confirmation(
            WatchUi.loadResource(Rez.Strings.ResetPrompt) as String
        );
        WatchUi.pushView(
            dialog,
            new ResetConfirmationDelegate(_view),
            WatchUi.SLIDE_IMMEDIATE
        );
        return true;
    }

    private function bump() as Void {
        _view.increment();
        playClick();
    }

    private function playClick() as Void {
        if ((Toybox has :Attention) && (Attention has :playTone)) {
            Attention.playTone(Attention.TONE_KEY);
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
