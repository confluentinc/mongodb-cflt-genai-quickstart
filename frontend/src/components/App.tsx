import React, { useState } from "react";
import Chat from "./Chat";
import Login from "./Login";

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
        <Login onLogin={handleLogin} />
      ) : (
        <Chat username={username} />
      )}
    </>
  );
}
