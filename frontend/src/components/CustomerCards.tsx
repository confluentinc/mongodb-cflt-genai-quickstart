import { useState, useEffect } from "react";
import Login from "./Login";
import CustomerCard from "./CustomerCard";

interface CustomerCardsProps {
  onLogin: (username: string) => void;
}

function CustomerCards({ onLogin }: CustomerCardsProps) {
  const [showLogin, setShowLogin] = useState(false);

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") {
        setShowLogin(false);
      }
    }

    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, []);

  function handleOpenLogin() {
    setShowLogin(true);
  }

  function handleCloseLogin() {
    setShowLogin(false);
  }

  return (
    <div className="flex flex-wrap md:flex-nowrap justify-around p-4">
      <CustomerCard
        title="New Customers"
        description="Discover personalized banking with competitive rates, secure transactions, and convenient digital solutions for your financial journey."
        onLogin={handleOpenLogin}
        type="new"
      />
      <CustomerCard
        title="Existing Customers"
        description="Elevate your banking experience with exclusive rewards, tailored financial advice, and seamless digital access for your ongoing financial goals."
        onLogin={handleOpenLogin}
        type="existing"
      />
      <CustomerCard
        title="Business Customers"
        description="Fuel your business success with tailored financial solutions, efficient digital banking tools, and expert support for your entrepreneurial journey."
        onLogin={handleOpenLogin}
        type="business"
      />
      {showLogin && (
        <div>
          <Login onLogin={onLogin} onClose={handleCloseLogin} />
        </div>
      )}
    </div>
  );
}

export default CustomerCards;
