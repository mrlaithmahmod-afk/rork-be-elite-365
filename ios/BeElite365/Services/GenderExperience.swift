import Foundation

struct GenderExperience {

    struct GenderProfile: Sendable {
        let affirmations: [String]
        let coachToneAdjustment: String
        let additionalSolveIssues: [String]
        let dashboardGreetingStyle: GreetingStyle
        let showAffirmationCard: Bool
        let showMotivationalQuote: Bool
        let dailyCardTitle: String
        let dailyCardIcon: String
    }

    nonisolated enum GreetingStyle: Sendable {
        case standard
        case empowering
    }

    static func profile(for gender: Gender) -> GenderProfile {
        switch gender {
        case .female:
            return GenderProfile(
                affirmations: femaleAffirmations,
                coachToneAdjustment: femaleCoachTone,
                additionalSolveIssues: ["Being overlooked", "Comparison to teammates", "Imposter syndrome", "Body image pressure"],
                dashboardGreetingStyle: .empowering,
                showAffirmationCard: true,
                showMotivationalQuote: false,
                dailyCardTitle: "TODAY'S AFFIRMATION",
                dailyCardIcon: "sparkles"
            )
        case .male:
            return GenderProfile(
                affirmations: maleMotivationalQuotes,
                coachToneAdjustment: "",
                additionalSolveIssues: [],
                dashboardGreetingStyle: .standard,
                showAffirmationCard: false,
                showMotivationalQuote: true,
                dailyCardTitle: "TODAY'S MOTIVATION",
                dailyCardIcon: "flame.fill"
            )
        case .preferNotToSay:
            return GenderProfile(
                affirmations: neutralAffirmations,
                coachToneAdjustment: "",
                additionalSolveIssues: [],
                dashboardGreetingStyle: .standard,
                showAffirmationCard: false,
                showMotivationalQuote: false,
                dailyCardTitle: "TODAY'S THOUGHT",
                dailyCardIcon: "bolt.fill"
            )
        }
    }

    static func todayAffirmation(for gender: Gender) -> String {
        let affirmations = profile(for: gender).affirmations
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % affirmations.count
        return affirmations[index]
    }

    private static let femaleAffirmations: [String] = [
        "I belong on this pitch. My presence is earned, not given.",
        "My strength is not a question. It is a fact.",
        "I do not shrink to make others comfortable.",
        "I trust my body, my instincts, my preparation.",
        "Pressure does not define me. How I respond does.",
        "I am building something no one can take from me.",
        "My confidence comes from within. Not from applause.",
        "I am allowed to take up space and demand the ball.",
        "Doubt is just noise. My work is the signal.",
        "I play for myself first. Everything else follows.",
        "My mistakes do not erase my ability.",
        "I am not here to prove I belong. I already do.",
        "I set the standard. I do not chase approval.",
        "My mindset is my greatest asset on and off the pitch.",
        "I am more than one bad moment. I am every moment of preparation.",
        "No one decides my ceiling. That is my job.",
        "I compete with who I was yesterday. No one else.",
        "My voice matters. On the pitch and in the room.",
        "I do not wait for permission to lead.",
        "Every session is a deposit into the player I am becoming.",
        "I am resilient. Setbacks are fuel, not endings.",
        "I choose courage over comfort. Every single time.",
        "My journey is unique. Comparison is a distraction.",
        "I am calm under pressure because I have prepared for this.",
        "Today I show up fully. That is enough.",
        "I trust the process even when results are slow.",
        "My energy is contagious. I lift the players around me.",
        "I do not need to be perfect. I need to be present.",
        "I control my effort, my attitude, and my response.",
        "I am exactly where I need to be right now.",
        "Criticism sharpens me. It does not break me.",
    ]

    static func todayMotivationalQuote(for gender: Gender) -> String {
        let quotes = profile(for: gender).affirmations
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % quotes.count
        return quotes[index]
    }

    private static let maleMotivationalQuotes: [String] = [
        "Pressure is a privilege. Only those who matter feel it.",
        "You weren't built for comfort. You were built for this.",
        "Discipline today. Dominance tomorrow.",
        "The work you put in when no one watches is the work that wins.",
        "Champions do not wait for motivation. They create it.",
        "Your body will quit a thousand times before your mind should.",
        "Be the hardest worker on the pitch. Every single session.",
        "The man who controls his mind controls the game.",
        "Average effort gets average results. You are not average.",
        "Fear is a compass. It points to where you need to go.",
        "One more rep. One more run. One more chance to be elite.",
        "The pitch does not care about excuses. Neither should you.",
        "Confidence is not hoping you will perform. It is knowing.",
        "Stop waiting for the right moment. Make this moment right.",
        "Pain is temporary. Regret lasts forever. Choose pain.",
        "You are one decision away from a completely different season.",
        "Respect is earned in the dark. Shown under the lights.",
        "Mental strength is not the absence of doubt. It is action despite doubt.",
        "Every setback is a setup for a stronger comeback.",
        "Your opponent trained today. Did you train harder?",
        "Silence the noise. Trust the process. Execute.",
        "You do not rise to the occasion. You fall to the level of your preparation.",
        "Be relentless. Not reckless. Relentless.",
        "Great players are not born in big moments. They are built in small ones.",
        "Attitude is the difference between an ordeal and an adventure.",
        "No one is coming to save you. That is your superpower.",
        "Control the controllables. Release everything else.",
        "The best version of you has no ceiling. Keep building.",
        "When the legs say stop, the mind says go. Train your mind.",
        "You earn your confidence in training. You spend it on matchday.",
        "Obsess over the process. The results will follow.",
        "Weak moments do not make weak men. Quitting does.",
        "Today's sacrifice is tomorrow's advantage.",
        "Play every minute like it is the minute that matters. Because it is.",
        "Your standards should scare average people.",
        "The grind is not punishment. It is preparation.",
        "You were not put here to be ordinary.",
        "Composure under pressure separates good from great.",
        "Where your focus goes, your performance flows.",
        "Do not count the days. Make the days count.",
        "Hunger beats talent when talent is not hungry.",
        "Be the player your teammates trust in the 90th minute.",
        "Every day you skip is a day your competition does not.",
        "Mentality is not a switch. It is a muscle. Train it daily.",
        "The scoreboard does not define you. Your effort does.",
        "Hard work compounds. Stay patient. Stay relentless.",
        "Be so prepared that confidence is your only option.",
        "When you feel like stopping, remember why you started.",
        "The game is won between your ears before it is won on the pitch.",
        "You are not tired. You are untested. Push further.",
        "Greatness is not a gift. It is a decision you make every morning.",
        "Leaders do not complain about the conditions. They adapt.",
        "Your next level requires a version of you that does not exist yet. Build him.",
        "Stay dangerous. Stay hungry. Stay locked in.",
        "Doubt kills more dreams than failure ever will.",
        "The world breaks everyone. And some become stronger at the broken places.",
        "If it were easy, everyone would be elite. It is not. You are.",
        "Show up. Shut up. Work. Repeat.",
        "Talent sets the floor. Work ethic sets the ceiling.",
        "Be the player coaches cannot leave out.",
        "Comfort is the enemy of progress. Stay uncomfortable.",
    ]

    private static let neutralAffirmations: [String] = [
        "I am prepared. I am present. I am ready.",
        "My mindset is my greatest advantage.",
        "I trust the work I have put in.",
        "Where my energy goes, my performance flows.",
        "I control my effort and my response. That is enough.",
    ]

    static let femaleCoachTone: String = """
    GENDER-AWARE COACHING CONTEXT:
    This player is female. Adapt naturally:
    - Acknowledge that women's football has unique pressures: visibility, comparison, being overlooked, having to prove belonging.
    - Never patronise. Never soften your message because of gender. Be equally direct and sharp.
    - If she raises issues around being taken seriously, not being seen, or imposter feelings — validate those as real and common in the women's game, then coach through them.
    - Use empowering language naturally. "You belong" and "You have earned this" are more powerful than "You can do it."
    - Reference the mental strength required to compete in environments that may not always support you equally.
    - Do NOT constantly reference gender. Only when it is genuinely relevant to the conversation.
    - Treat her as an elite competitor first. Gender context is background, not the headline.
    """
}
