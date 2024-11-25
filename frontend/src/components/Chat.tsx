import { WS_URL } from "astro:env/client";
import useWebSocket, { ReadyState } from "react-use-websocket";
import React, { useState, useCallback } from "react";
import ChatInput from "./ChatInput.tsx";
import ChatMessages from "./ChatMessages.tsx";
import type { ChatMessage } from "./ChatMessage.tsx";
import type { ClientMessage } from "./ClientMessage.tsx";
import type { WebSocketServerMessage } from "./WebSocketServerMessage.tsx";

/**
 * Chat component that handles user input and displays chat messages.
 * Utilizes the useChat hook for managing chat state and interactions.
 */
export default function Chat({ username }: { username: string }) {
  const [isChatOpen, setIsChatOpen] = useState(false);

  const toggleChat = () => {
    setIsChatOpen(!isChatOpen);
  };

  const [input, setInput] = useState("");
  const [messageHistory, setMessageHistory] = useState<ChatMessage[]>([]);

  const handleMessage = useCallback((event: WebSocketEventMap["message"]) => {
    console.log(event);
    // if the message is valid json, parse it and add it to the message history
    try {
      const message: WebSocketServerMessage = JSON.parse(event.data);
      const chatMessage: ChatMessage = {
        role: "server",
        userId: message.userId,
        data: message.output,
      };
      setMessageHistory((prev) => prev.concat(chatMessage));
    } catch (e) {
      console.debug("Invalid JSON message received:", event.data);
    }
  }, []);

  const { sendJsonMessage, readyState } = useWebSocket<ChatMessage>(WS_URL, {
    onOpen: () => console.log("WebSocket connection opened!"),
    onClose: (event) => console.log("WebSocket connection closed!: ", event),
    onError: (event) => console.error("WebSocket error:", event),
    onMessage: handleMessage,
  });

  const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setInput(event.target.value);
  };

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (input.trim() === "") return;

    const chatMessage: ChatMessage = {
      role: "client",
      userId: username,
      data: input,
    };
    setMessageHistory((prev) => prev.concat(chatMessage));
    const clientMessage: ClientMessage = {
      userId: chatMessage.userId,
      input:
        messageHistory
          .map(
            (message) =>
              (message.role === "client" ? "Human: " : "Assistant: ") +
              message.data,
          )
          .join("\n") +
        (messageHistory.length > 0 ? "\nHuman: " : "Human: ") +
        input,
    };

    console.log(clientMessage);

    sendJsonMessage(clientMessage);
    setInput("");
  };

  return (
    <div>
      <button
        className="fixed bottom-4 right-4 bg-blue-500 text-white p-3 rounded-full shadow-lg"
        onClick={toggleChat}
      >
        Chat
      </button>
      {isChatOpen && (
        <div className="fixed bottom-16 right-4 bg-gray-800 text-white rounded-lg shadow-lg flex flex-col w-1/3">
          <div className="flex justify-between items-center p-4 bg-blue-500 rounded-t-lg">
            <h1 className="text-xl font-bold">Big Friendly Bank</h1>
            <button onClick={toggleChat} className="text-white">
              X
            </button>
          </div>
          <div className="flex flex-col flex-grow w-full max-w-screen-lg rounded-lg h-full overflow-y-auto">
            <ChatMessages messages={messageHistory} />
            <ChatInput
              input={input}
              handleSubmit={handleSubmit}
              handleInputChange={handleInputChange}
              isDisabled={readyState !== ReadyState.OPEN}
            />
          </div>
        </div>
      )}
    </div>
  );
}
