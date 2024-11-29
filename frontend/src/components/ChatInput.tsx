import React from "react";

interface ChatInputProps {
  input: string;
  handleSubmit: (event: React.FormEvent<HTMLFormElement>) => void;
  handleInputChange: (event: React.ChangeEvent<HTMLInputElement>) => void;
  isDisabled: boolean;
}

const ChatInput: React.FC<ChatInputProps> = ({
  input,
  handleSubmit,
  handleInputChange,
  isDisabled,
}) => {
  return (
    <div className="bg-gray-500 p-4">
      <form onSubmit={handleSubmit}>
        <input
          className="flex items-center h-10 w-full rounded px-3 text-sm text-black"
          value={input}
          placeholder="What's your question?"
          autoFocus
          onChange={handleInputChange}
          disabled={isDisabled}
          ref={(input) => input && input.focus()}
        />
      </form>
    </div>
  );
};

export default ChatInput;
