import {WS_URL} from "astro:env/client";
import useWebSocket, {ReadyState} from "react-use-websocket";
import React, {useState, useCallback} from "react";
import ChatInput from "./ChatInput.tsx";
import ChatMessages from "./ChatMessages.tsx";
import type {ChatMessage} from "./ChatMessage.tsx";
import type {ClientMessage} from "./ClientMessage.tsx";
import type {WebSocketServerMessage} from "./WebSocketServerMessage.tsx";

/**
 * Chat component that handles user input and displays chat messages.
 * Utilizes the useChat hook for managing chat state and interactions.
 */
export default function Chat() {
    const [input, setInput] = useState("");
    const [messageHistory, setMessageHistory] = useState<ChatMessage[]>([]);

    const handleMessage = useCallback((event: WebSocketEventMap['message']) => {
        console.log(event);
        // if the message is valid json, parse it and add it to the message history
        try {
            const message: WebSocketServerMessage = JSON.parse(event.data);
            const chatMessage: ChatMessage = {
                role: "server",
                userId: message.userId,
                data: message.output
            }
            setMessageHistory((prev) => prev.concat(chatMessage));
        } catch (e) {
            console.debug('Invalid JSON message received:', event.data);
        }
    }, []);

    const {sendJsonMessage, readyState} = useWebSocket<ChatMessage>(WS_URL, {
        onOpen: () => console.log('WebSocket connection opened!'),
        onClose: (event) => console.log('WebSocket connection closed!: ', event),
        onError: (event) => console.error('WebSocket error:', event),
        onMessage: handleMessage
    });

    const handleInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setInput(event.target.value);
    };

    const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
        event.preventDefault();
        if (input.trim() === "") return;


        // TODO: Update userId with actual user ID
        const chatMessage: ChatMessage = {
            role: "client",
            userId: "blah",
            data: input
        }
        setMessageHistory((prev) => prev.concat(chatMessage));
        const clientMessage: ClientMessage = {
            userId: chatMessage.userId,
            input: messageHistory.map((message) => (message.role === "client" ? "Human: " : "Assistant: ") + message.data).join("\n") + (messageHistory.length > 0 ? "\nHuman: " : "Human: ") + input
        }

        console.log(clientMessage);

        sendJsonMessage(clientMessage);
        setInput("");
    };

    return (
        <>
            <h1 className="text-3xl mb-6 font-bold text-center">
                Big Friendly Bank
            </h1>
            <div className="flex flex-col flex-grow w-full max-w-screen-lg rounded-lg h-96 overflow-y-auto">
                <ChatMessages messages={messageHistory}/>
                <ChatInput
                    input={input}
                    handleSubmit={handleSubmit}
                    handleInputChange={handleInputChange}
                    isDisabled={readyState !== ReadyState.OPEN}
                />
            </div>
        </>
    );
}