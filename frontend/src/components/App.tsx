import { useState } from "react";
import CustomerCards from "./CustomerCards";
import Dashboard from "./Dashboard"; // Import the new Dashboard component

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
        <Dashboard username={username} />
      )}
    </>
  );
}
