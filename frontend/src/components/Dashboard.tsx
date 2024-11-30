import Chat from "./Chat";
import {
  FaHome,
  FaExchangeAlt,
  FaUser,
  FaChartLine,
  FaCreditCard,
  FaMoneyCheckAlt,
  FaCog,
  FaApple,
  FaPinterest,
  FaFilm,
} from "react-icons/fa";

export default function Dashboard({ username }: { username: string }) {
  return (
    <>
      <div className="min-h-screen bg-gray-100">
        <section className="flex">
          <nav className="bg-white w-64 p-5 border-r border-gray-200 hidden md:block">
            <ul className="flex flex-col gap-1">
              <li>
                <a
                  className="flex items-center gap-4 py-2 px-4 text-gray-700 hover:text-blue-600"
                  href="#/"
                >
                  <FaHome size={25} />
                  <p>Dashboard</p>
                </a>
              </li>
              <li>
                <a
                  className="flex items-center gap-4 py-2 px-4 text-gray-700 hover:text-blue-600"
                  href="#/transactions"
                >
                  <FaExchangeAlt size={25} />
                  <p>Transactions</p>
                </a>
              </li>
              <li>
                <a
                  className="flex items-center gap-4 py-2 px-4 text-gray-700 hover:text-blue-600"
                  href="#/accounts"
                >
                  <FaUser size={25} />
                  <p>Accounts</p>
                </a>
              </li>
              <li>
                <a
                  className="flex items-center gap-4 py-2 px-4 text-gray-700 hover:text-blue-600"
                  href="#/investments"
                >
                  <FaChartLine size={25} />
                  <p>Investments</p>
                </a>
              </li>
              <li>
                <a
                  className="flex items-center gap-4 py-2 px-4 text-gray-700 hover:text-blue-600"
                  href="#/cards"
                >
                  <FaCreditCard size={25} />
                  <p>Credit Cards</p>
                </a>
              </li>
              <li>
                <a
                  className="flex items-center gap-4 py-2 px-4 text-gray-700 hover:text-blue-600"
                  href="#/loans"
                >
                  <FaMoneyCheckAlt size={25} />
                  <p>Loans</p>
                </a>
              </li>
              <li>
                <a
                  className="flex items-center gap-4 py-2 px-4 text-gray-700 hover:text-blue-600"
                  href="#/services"
                >
                  <FaCog size={25} />
                  <p>Services</p>
                </a>
              </li>
              <li>
                <a
                  className="flex items-center gap-4 py-2 px-4 text-gray-700 hover:text-blue-600"
                  href="#/setting"
                >
                  <FaCog size={25} />
                  <p>Setting</p>
                </a>
              </li>
            </ul>
          </nav>

          <div className="flex-grow p-6 space-y-6">
            {/* Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Card 1 */}
              <div className="bg-white p-5 rounded-md shadow">
                <p className="text-sm text-gray-600">Total Balance</p>
                <p className="text-2xl font-semibold text-gray-800">
                  $12,345.67
                </p>
              </div>
              {/* Card 2 */}
              <div className="bg-white p-5 rounded-md shadow">
                <p className="text-sm text-gray-600">Monthly Spending</p>
                <p className="text-2xl font-semibold text-gray-800">
                  $2,345.67
                </p>
              </div>
              {/* Card 3 */}
              <div className="bg-white p-5 rounded-md shadow">
                <p className="text-sm text-gray-600">Upcoming Bills</p>
                <p className="text-2xl font-semibold text-gray-800">
                  $1,234.56
                </p>
              </div>
            </div>

            {/* Credit Cards Section */}
            <section className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {/* Credit Card 1 */}
              <div className="bg-gradient-to-tr from-blue-400 to-blue-600 text-white rounded-xl overflow-hidden">
                <div className="px-6 py-5 space-y-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm">Balance</p>
                      <p className="text-2xl">$5,756</p>
                    </div>
                    <img src="card-symbol.png" className="w-[35px]" />
                  </div>
                  <div className="grid grid-cols-2 gap-5">
                    <div className="space-y-1">
                      <p className="text-sm text-white/80">CARD HOLDER</p>
                      <p className="text-xl">Eddy Cusuma</p>
                    </div>
                    <div className="space-y-1">
                      <p className="text-sm text-white/80">VALID THRU</p>
                      <p className="text-xl">12/25</p>
                    </div>
                  </div>
                </div>
                <div className="bg-gradient-to-br from-white/15 to-transparent flex items-center justify-between px-6 py-4">
                  <p className="font-semibold text-xl">3778 **** **** 1234</p>
                  <img
                    src="data:image/svg+xml,%3csvg%20xmlns='http://www.w3.org/2000/svg'%20width='44'%20height='30'%20viewBox='0%200%2044%2030'%20fill='none'%3e%3ccircle%20cx='15'%20cy='15'%20r='15'%20fill='white'%20fill-opacity='0.5'/%3e%3ccircle%20cx='29'%20cy='15'%20r='15'%20fill='white'%20fill-opacity='0.5'/%3e%3c/svg%3e"
                    className="w-[50px]"
                  />
                </div>
              </div>
              {/* Credit Card 2 */}
              <div className="bg-gradient-to-tr from-green-400 to-green-600 text-white rounded-xl overflow-hidden">
                <div className="px-6 py-5 space-y-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm">Balance</p>
                      <p className="text-2xl">$3,456</p>
                    </div>
                    <img src="card-symbol.png" className="w-[35px]" />
                  </div>
                  <div className="grid grid-cols-2 gap-5">
                    <div className="space-y-1">
                      <p className="text-sm text-white/80">CARD HOLDER</p>
                      <p className="text-xl">John Doe</p>
                    </div>
                    <div className="space-y-1">
                      <p className="text-sm text-white/80">VALID THRU</p>
                      <p className="text-xl">08/25</p>
                    </div>
                  </div>
                </div>
                <div className="bg-gradient-to-br from-white/15 to-transparent flex items-center justify-between px-6 py-4">
                  <p className="font-semibold text-xl">1234 **** **** 5678</p>
                  <img
                    src="data:image/svg+xml,%3csvg%20xmlns='http://www.w3.org/2000/svg'%20width='44'%20height='30'%20viewBox='0%200%2044%2030'%20fill='none'%3e%3ccircle%20cx='15'%20cy='15'%20r='15'%20fill='white'%20fill-opacity='0.5'/%3e%3ccircle%20cx='29'%20cy='15'%20r='15'%20fill='white'%20fill-opacity='0.5'/%3e%3c/svg%3e"
                    className="w-[50px]"
                  />
                </div>
              </div>
              {/* Credit Card 3 */}
              <div className="bg-gradient-to-tr from-red-400 to-red-600 text-white rounded-xl overflow-hidden">
                <div className="px-6 py-5 space-y-6">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm">Balance</p>
                      <p className="text-2xl">$7,890</p>
                    </div>
                    <img src="card-symbol.png" className="w-[35px]" />
                  </div>
                  <div className="grid grid-cols-2 gap-5">
                    <div className="space-y-1">
                      <p className="text-sm text-white/80">CARD HOLDER</p>
                      <p className="text-xl">Jane Smith</p>
                    </div>
                    <div className="space-y-1">
                      <p className="text-sm text-white/80">VALID THRU</p>
                      <p className="text-xl">03/25</p>
                    </div>
                  </div>
                </div>
                <div className="bg-gradient-to-br from-white/15 to-transparent flex items-center justify-between px-6 py-4">
                  <p className="font-semibold text-xl">9012 **** **** 3456</p>
                  <img
                    src="data:image/svg+xml,%3csvg%20xmlns='http://www.w3.org/2000/svg'%20width='44'%20height='30'%20viewBox='0%200%2044%2030'%20fill='none'%3e%3ccircle%20cx='15'%20cy='15'%20r='15'%20fill='white'%20fill-opacity='0.5'/%3e%3ccircle%20cx='29'%20cy='15'%20r='15'%20fill='white'%20fill-opacity='0.5'/%3e%3c/svg%3e"
                    className="w-[50px]"
                  />
                </div>
              </div>
            </section>

            {/* Latest Transfers */}
            <section className="bg-white p-6 rounded-md shadow">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-xl font-semibold text-gray-800">
                  Latest Transfers
                </h2>
                <div className="flex items-center space-x-2">
                  <p className="text-sm text-gray-800">
                    Filter selected: more than $100
                  </p>
                  <button className="p-2 rounded-full hover:bg-gray-100">
                    <i className="ph-funnel"></i>
                  </button>
                  <button className="p-2 rounded-full hover:bg-gray-100">
                    <i className="ph-plus"></i>
                  </button>
                </div>
              </div>
              <div className="space-y-6">
                <div className="flex flex-col md:flex-row justify-between items-center p-6 bg-slate-200 rounded-md">
                  <div className="flex items-center flex-1 gap-6">
                    <FaApple className="w-12 h-12 text-black" />
                    <dl className="grid grid-cols-1 md:grid-cols-3 gap-8 w-full">
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">
                          Apple Inc.
                        </dt>
                        <dd className="text-sm text-gray-700">
                          Apple ID Payment
                        </dd>
                      </div>
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">
                          Card Ending:
                        </dt>
                        <dd className="text-sm text-gray-700">4012</dd>
                      </div>
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">Date:</dt>
                        <dd className="text-sm text-gray-700">28 Oct. 2024</dd>
                      </div>
                    </dl>
                  </div>
                  <div className="text-red-600 font-semibold ml-6">- $550</div>
                </div>

                <div className="flex flex-col md:flex-row justify-between items-center p-6 bg-slate-200 rounded-md">
                  <div className="flex items-center flex-1 gap-6">
                    <FaPinterest className="w-12 h-12 text-red-500" />
                    <dl className="grid grid-cols-1 md:grid-cols-3 gap-8 w-full">
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">
                          Pinterest
                        </dt>
                        <dd className="text-sm text-gray-700">
                          2 year subscription
                        </dd>
                      </div>
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">
                          Card Ending:
                        </dt>
                        <dd className="text-sm text-gray-700">5214</dd>
                      </div>
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">Date:</dt>
                        <dd className="text-sm text-gray-700">26 Oct. 2024</dd>
                      </div>
                    </dl>
                  </div>
                  <div className="text-red-600 font-semibold ml-6">- $120</div>
                </div>
                <div className="flex flex-col md:flex-row justify-between items-center p-6 bg-slate-200 rounded-md">
                  <div className="flex items-center flex-1 gap-6">
                    <FaFilm className="w-12 h-12 text-yellow-500" />
                    <dl className="grid grid-cols-1 md:grid-cols-3 gap-8 w-full">
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">
                          Warner Bros.
                        </dt>
                        <dd className="text-sm text-gray-700">Cinema</dd>
                      </div>
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">
                          Card Ending:
                        </dt>
                        <dd className="text-sm text-gray-700">2228</dd>
                      </div>
                      <div className="flex flex-col items-start">
                        <dt className="font-semibold text-gray-800">Date:</dt>
                        <dd className="text-sm text-gray-700">22 Oct. 2024</dd>
                      </div>
                    </dl>
                  </div>
                  <div className="text-red-600 font-semibold ml-6">- $70</div>
                </div>
              </div>
            </section>
          </div>
        </section>
      </div>
        <Chat username={username} />
    </>
  );
}
