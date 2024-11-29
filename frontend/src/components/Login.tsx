import { useState } from "react";
import type { FormEvent, ChangeEvent } from "react";

interface LoginProps {
  onLogin: (username: string) => void;
  onClose: () => void;
}

interface Errors {
  username: string;
  password: string;
}

function Login({ onLogin, onClose }: LoginProps) {
  const [username, setUsername] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [errors, setErrors] = useState<Errors>({ username: "", password: "" });

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    let valid = true;
    let newErrors: Errors = { username: "", password: "" };

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
    <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
      <form
        onSubmit={handleSubmit}
        className="relative flex flex-col bg-white shadow-sm border border-slate-200 w-96 rounded-lg my-6"
      >
        <div className="relative m-2.5 items-center flex justify-center text-white h-24 rounded-md bg-slate-800">
          <h3 className="text-2xl">Sign In</h3>
          <button
            type="button"
            onClick={onClose}
            className="absolute top-2 right-2 text-white bg-transparent hover:text-gray-400"
          >
            &times;
          </button>
        </div>
        <div className="flex flex-col gap-4 p-6">
          <div className="w-full max-w-sm min-w-[200px]">
            <label className="block mb-2 text-sm text-slate-600">
              Username
            </label>
            <input
              type="text"
              name="username"
              placeholder="Username"
              value={username}
              onChange={(e: ChangeEvent<HTMLInputElement>) =>
                setUsername(e.target.value)
              }
              required
              className={`w-full bg-transparent placeholder:text-slate-400 text-slate-700 text-sm border border-slate-200 rounded-md px-3 py-2 transition duration-300 ease focus:outline-none focus:border-slate-400 hover:border-slate-300 shadow-sm focus:shadow ${errors.username ? "border-red-500" : ""}`}
            />
            {errors.username && (
              <p className="text-red-500 text-sm mb-4">{errors.username}</p>
            )}
          </div>
          <div className="w-full max-w-sm min-w-[200px]">
            <label className="block mb-2 text-sm text-slate-600">
              Password
            </label>
            <input
              type="password"
              name="password"
              placeholder="Password"
              value={password}
              onChange={(e: ChangeEvent<HTMLInputElement>) =>
                setPassword(e.target.value)
              }
              required
              className={`w-full bg-transparent placeholder:text-slate-400 text-slate-700 text-sm border border-slate-200 rounded-md px-3 py-2 transition duration-300 ease focus:outline-none focus:border-slate-400 hover:border-slate-300 shadow-sm focus:shadow ${errors.password ? "border-red-500" : ""}`}
            />
            {errors.password && (
              <p className="text-red-500 text-sm mb-4">{errors.password}</p>
            )}
          </div>
          <div className="inline-flex items-center mt-2">
            <label
              className="flex items-center cursor-pointer relative"
              htmlFor="remember-me"
            >
              <input
                type="checkbox"
                className="peer h-5 w-5 cursor-pointer transition-all appearance-none rounded shadow hover:shadow-md border border-slate-300 checked:bg-slate-800 checked:border-slate-800"
                id="remember-me"
              />
              <span className="absolute text-white opacity-0 pointer-events-none peer-checked:opacity-100 top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-3.5 w-3.5"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  stroke="currentColor"
                  strokeWidth="1"
                >
                  <path
                    fillRule="evenodd"
                    d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                    clipRule="evenodd"
                  ></path>
                </svg>
              </span>
            </label>
            <label
              className="cursor-pointer ml-2 text-slate-600 text-sm"
              htmlFor="remember-me"
            >
              Remember Me
            </label>
          </div>
        </div>
        <div className="p-6 pt-0">
          <button
            type="submit"
            className="w-full rounded-md bg-slate-800 py-2 px-4 border border-transparent text-center text-sm text-white transition-all shadow-md hover:shadow-lg focus:bg-slate-700 focus:shadow-none active:bg-slate-700 hover:bg-slate-700 active:shadow-none disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none"
          >
            Sign In
          </button>
          <button
            type="button"
            onClick={onClose}
            className="w-full mt-4 rounded-md bg-red-600 py-2 px-4 border border-transparent text-center text-sm text-white transition-all shadow-md hover:shadow-lg focus:bg-red-500 focus:shadow-none active:bg-red-500 hover:bg-red-500 active:shadow-none disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none"
          >
            Close
          </button>
          <p className="flex justify-center mt-6 text-sm text-slate-600">
            Don&apos;t have an account?
            <a
              href="#signup"
              className="ml-1 text-sm font-semibold text-slate-700 underline"
            >
              Sign up
            </a>
          </p>
        </div>
      </form>
    </div>
  );
}

export default Login;
