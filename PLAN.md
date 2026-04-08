# Rebuild Mental Mentor as a Real-Time AI Agent

## What's Changing

The entire Coach / Mental Mentor system is being rebuilt from the ground up. No more canned responses, no response libraries, no if/else trees. Every single response will be generated live by the AI model in real-time.

---

## Features

- **100% AI-Generated Responses** — Every reply comes from the language model. No hardcoded phrases. The AI thinks on the spot like ChatGPT.
- **Streaming Responses** — Text appears word-by-word in real-time as the AI generates it, just like ChatGPT. No waiting for full message.
- **Natural Conversation** — The AI talks like a calm, composed human coach. It answers "hi" with "hi". It answers "how are you?" normally. It doesn't force frameworks on casual messages.
- **Deep Coaching When Needed** — When the player brings up a real issue (nerves, mistakes, pressure), the AI naturally weaves in Reset → Regroup → Refocus guidance without rigid card formatting.
- **Full Player Context** — Before every response, the AI receives the player's name, position, level, confidence trends, recent drills, next match, emotional patterns — all injected invisibly into the prompt.
- **Conversation Memory** — Last 20 messages are sent with every request so the AI remembers what was just discussed. History persists across app sessions.
- **Voice Call Mode** — Full-screen voice interaction that feels like a phone call with a coach. Tap to speak, AI responds in voice. Shows "Listening...", "Thinking...", "Speaking..." states.
- **Speech Input** — Tap the mic, speak naturally, speech is transcribed and sent to the AI.
- **Voice Output** — AI responses are spoken back in a calm, composed voice.
- **No Connection Handling** — If the server is unreachable, a clear "no connection" message appears. No fake responses.
- **Smart Intent Hints** — A lightweight classifier hints to the AI whether the message is casual, emotional, or performance-related — but the AI still generates everything dynamically.
- **Suggested Actions** — After coaching responses, contextual drill suggestions appear (e.g. "Try a 10-Second Reset") based on what the AI discussed.
- **Crisis Safety** — Messages mentioning self-harm are intercepted before reaching the AI, showing professional support resources instead.

---

## Design

- **Chat Screen** — Clean message bubbles with streaming text. Gold accent for user messages, subtle grey for coach responses. Typing indicator replaced by live streaming text.
- **Streaming Feel** — Words appear progressively in the coach bubble as they're generated, creating that "thinking in real-time" feel.
- **Input Bar** — Text field with mic button on the left, send button on the right. Clean, minimal.
- **Voice Mode** — Full-screen dark overlay. Large pulsing mic button. State labels (Listening / Thinking / Speaking). Transcript visible. Feels like a private phone call.
- **Suggested Drills** — Small capsule buttons below the last message when relevant. Gold accent, tappable.
- **No Structured Cards** — The RESET/REGROUP/REFOCUS card layout is removed. All responses are natural flowing text. The AI will naturally reference the 3R framework when coaching, but as conversation, not boxes.

---

## Screens

- **Coach Tab (Chat)** — The main chat interface with streaming AI responses, message history, mic button, and suggested actions
- **Voice Mode (Full Screen)** — Overlay for voice-first interaction with the coach, showing real-time transcription and speaking states

---

## Technical Approach

- **Streaming API** — The toolkit chat endpoint will be called with streaming enabled so text arrives progressively
- **Simplified Agent** — Remove all hardcoded response libraries and local response generation. The agent only handles: context building, prompt construction, streaming orchestration, and crisis detection
- **Rebuilt Prompt System** — Single, powerful system prompt that defines the coach's personality, conversation rules, and when to apply the mental framework — all enforced by the AI model, not code
- **Lightweight Intent Hints** — Intent classification stays but only adjusts prompt emphasis (e.g. "keep it short" for greetings vs "use the framework" for coaching). It never generates responses.
- **Conversation Persistence** — Messages stored in SwiftData as before, restored on app relaunch
