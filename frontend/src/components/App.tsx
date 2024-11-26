import React, { useState } from "react";
import Chat from "./Chat";
import CustomerCards from "./CustomerCards";

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [username, setUsername] = useState("");

  function handleLogin(username: string) {
    setUsername(username);
    setIsLoggedIn(true);
  }

  return (
    <>
      {!isLoggedIn ? (
        <CustomerCards onLogin={handleLogin} />
      ) : (
        <Chat username={username} />
      )}
    </>
  );
}
