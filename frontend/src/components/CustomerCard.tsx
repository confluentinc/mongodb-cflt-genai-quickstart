interface CustomerCardProps {
  title: string;
  description: string;
  onLogin: () => void;
  type: "business" | "existing" | "new";
}

function CustomerCard({
  title,
  description,
  onLogin,
  type,
}: CustomerCardProps) {
  const renderIcon = () => {
    switch (type) {
      case "business":
        return (
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth="1.5"
            stroke="currentColor"
            className="w-10 h-10 text-blue-400"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M3 7h18M3 7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2m-18 0v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V7M9 10h6M9 14h6"
            />
          </svg>
        );
      case "existing":
        return (
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 16 16"
            fill="none"
            className="w-10 h-10 text-blue-400"
          >
            <g id="SVGRepo_bgCarrier" strokeWidth="0" />
            <g
              id="SVGRepo_tracerCarrier"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <g id="SVGRepo_iconCarrier">
              <path
                d="M8 7C9.65685 7 11 5.65685 11 4C11 2.34315 9.65685 1 8 1C6.34315 1 5 2.34315 5 4C5 5.65685 6.34315 7 8 7Z"
                className="fill-current "
              />
              <path
                d="M14 12C14 10.3431 12.6569 9 11 9H5C3.34315 9 2 10.3431 2 12V15H14V12Z"
                className="fill-current"
              />
            </g>
          </svg>
        );
      case "new":
        return (
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth="1.5"
            stroke="currentColor"
            className="w-10 h-10 text-blue-400"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M12 4.5v15m7.5-7.5h-15"
            />
          </svg>
        );
      default:
        return null;
    }
  };

  return (
    <div className="relative min-h-96 w-full md:w-1/4 flex flex-col justify-center items-center my-4 mx-2 bg-white shadow-lg border border-slate-200 rounded-lg p-4">
      <div className="p-3 text-center space-y-4">
        <div className="flex justify-center">{renderIcon()}</div>
        <div className="flex justify-center">
          <h5 className="text-slate-800 text-2xl font-semibold">{title}</h5>
        </div>
        <p className="block text-slate-600 leading-normal font-light max-w-lg">
          {description}
        </p>
        <div className="text-center">
          <button
            className="min-w-32 rounded-md bg-slate-800 py-2 px-4 border border-transparent text-center text-sm text-white transition-all shadow-md hover:shadow-lg focus:bg-slate-700 focus:shadow-none active:bg-slate-700 hover:bg-slate-700 active:shadow-none"
            onClick={onLogin}
          >
            Login
          </button>
        </div>
      </div>
    </div>
  );
}

export default CustomerCard;
