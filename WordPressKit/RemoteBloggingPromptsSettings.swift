public struct RemoteBloggingPromptsSettings: Codable {
    public var promptCardEnabled: Bool
    public var promptRemindersEnabled: Bool
    public var reminderDays: ReminderDays
    public var reminderTime: String
    public var isPotentialBloggingSite: Bool

    public struct ReminderDays: Codable {
        public var monday: Bool
        public var tuesday: Bool
        public var wednesday: Bool
        public var thursday: Bool
        public var friday: Bool
        public var saturday: Bool
        public var sunday: Bool
    }

    private enum CodingKeys: String, CodingKey {
        case promptCardEnabled = "prompts_card_opted_in"
        case promptRemindersEnabled = "prompts_reminders_opted_in"
        case reminderDays = "reminders_days"
        case reminderTime = "reminders_time"
        case isPotentialBloggingSite = "is_potential_blogging_site"
    }
}
