import { useState } from "react";

function Login({ onLogin }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState({ username: "", password: "" });

  const handleSubmit = (e) => {
    e.preventDefault();
    let valid = true;
    let newErrors = { username: "", password: "" };

    if (username.trim() === "") {
      newErrors.username = "Username is required";
      valid = false;
    }

    if (password.trim() === "") {
      newErrors.password = "Password is required";
      valid = false;
    }

    setErrors(newErrors);

    if (valid) {
      onLogin(username);
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="flex flex-col items-center bg-white p-6 rounded-lg shadow-md prose"
    >
      <h2 className="text-2xl font-bold mb-4 text-black">Login</h2>
      <input
        type="text"
        name="username"
        placeholder="Username"
        value={username}
        onChange={(e) => setUsername(e.target.value)}
        required
        className={`mb-2 p-2 border rounded w-full ${errors.username ? "border-red-500" : "border-gray-300"}`}
      />
      {errors.username && (
        <p className="text-red-500 text-sm mb-4">{errors.username}</p>
      )}
      <input
        type="password"
        name="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        required
        className={`mb-2 p-2 border rounded w-full ${errors.password ? "border-red-500" : "border-gray-300"}`}
      />
      {errors.password && (
        <p className="text-red-500 text-sm mb-4">{errors.password}</p>
      )}
      <button
        type="submit"
        className="p-2 bg-blue-500 text-white rounded w-full hover:bg-blue-600"
      >
        Login
      </button>
    </form>
  );
}

export default Login;
