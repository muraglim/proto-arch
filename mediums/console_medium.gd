class_name ConsoleMedium
extends Medium

var _channel: ConsoleChannel = null

func geist_shutdown() -> void:
    _log("geist_shutdown(): medium offline.")

func set_channel(channel: ConsoleChannel) -> void:
    _channel = channel

func compose(context_key: String, data: Dictionary = {}) -> void:
    if Guard.is_unresolved(_channel, name + ":compose"): return
    var format_string = Firm.get_value("core_text_ledger", context_key)
    if Guard.is_unresolved(format_string, name + ":compose"): return
    _channel.display(format_string.format(data))
