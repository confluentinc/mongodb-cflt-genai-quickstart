import { WS_URL } from "astro:env/client";
import useWebSocket, { ReadyState } from "react-use-websocket";
import React, { useState, useCallback } from "react";
import ChatInput from "./ChatInput.tsx";
import ChatMessages from "./ChatMessages.tsx";
import type { ChatMessage } from "./ChatMessage.tsx";
import type { ClientMessage } from "./ClientMessage.tsx";
import type { WebSocketServerMessage } from "./WebSocketServerMessage.tsx";
import { LiaCommentsDollarSolid } from "react-icons/lia"; // Re-add this import for the chat icon

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
  const [isLoading, setIsLoading] = useState(false); // Add this line

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
    setIsLoading(false); // Add this line
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

    setIsLoading(true); // Add this line

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
    <div className="relative">
      <button
        className="fixed bottom-20 right-4 bg-blue-500 text-white p-3 rounded-full shadow-lg flex items-center justify-center w-12 h-12"
        onClick={toggleChat}
      >
        <LiaCommentsDollarSolid size={40} />
      </button>
      {isChatOpen && (
        <div className="fixed bottom-32 right-4 bg-gray-800 text-white rounded-lg shadow-lg flex flex-col w-11/12 md:w-1/3">
          <div className="flex justify-between items-center p-4 bg-blue-500 rounded-t-lg">
            <h1 className="text-xl font-bold">Big Friendly Bank</h1>
            <button onClick={toggleChat} className="text-white">
              X
            </button>
          </div>
          <div className="flex flex-col flex-grow w-full max-w-screen-lg rounded-lg h-full overflow-y-auto">
            <ChatMessages messages={messageHistory} isLoading={isLoading} />
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
