import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Shortener from "./Shortener";   // rename your existing App.js to Shortener.js
import Analytics from "./Analytics";

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-100">
        <nav className="bg-white shadow-md p-4 flex justify-between">
          <Link to="/" className="text-blue-600 font-semibold">Shortener</Link>
          <Link to="/analytics" className="text-green-600 font-semibold">Analytics</Link>
        </nav>

        <Routes>
          <Route path="/" element={<Shortener />} />
          <Route path="/analytics" element={<Analytics />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
