import React, {useEffect, useRef} from 'react';
import Markdown from 'react-markdown';
import type {ChatMessage} from "./ChatMessage.tsx";

interface ChatMessagesProps {
    messages: ChatMessage[];
}

const ChatMessages: React.FC<ChatMessagesProps> = ({messages}) => {
    const messagesEndRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        if (messagesEndRef.current) {
            messagesEndRef.current.scrollIntoView({behavior: 'smooth', block: 'nearest', inline: 'start'});
        }
    }, [messages]);

    return (
        <div className="flex flex-col flex-grow h-96 p-4 overflow-y-auto bg-gray-800">
            {messages.map((m, index) => (
                <div key={index}
                    className={`whitespace-pre-wrap mt-2 space-x-3 w-9/12 ${m.role === "client" ? "" : "ml-auto justify-end"}`}>
                    <div>
                        <div
                            className={`p-3 rounded-r-lg rounded-bl-lg ${m.role === "client" ? "bg-blue-500" : "bg-gray-700"}`}>
                            <Markdown
                                className={"prose prose-invert prose-li:marker:text-white"}>{m.data}</Markdown>
                        </div>
                    </div>
                </div>
            ))}
            <div ref={messagesEndRef}/>
        </div>
    );
};

export default ChatMessages;