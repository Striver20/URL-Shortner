import { useState } from "react";
import axios from "axios";

function Shortener() {
  const [url, setUrl] = useState("");
  const [owner, setOwner] = useState("");
  const [expiryDate, setExpiryDate] = useState("");
  const [responseData, setResponseData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setResponseData(null);

    try {
      const response = await axios.post("http://localhost:8080/api/v1/shorten", {
        url,
        owner,
        expiryDate,
      });

      setResponseData(response.data); // now contains full DTO
    } catch (err) {
      if (err.response) {
        setError(err.response.data.message || "Failed to shorten URL");
      } else if (err.request) {
        setError("No response from server");
      } else {
        setError(err.message);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="bg-white shadow-xl rounded-2xl p-8 w-full max-w-lg">
        <h1 className="text-2xl font-bold text-center mb-6">URL Shortener</h1>

        <form onSubmit={handleSubmit} className="space-y-4">
          <input
            type="text"
            placeholder="Enter your long URL"
            value={url}
            onChange={(e) => setUrl(e.target.value)}
            required
            className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          />

          <input
            type="text"
            placeholder="Enter owner name (optional)"
            value={owner}
            onChange={(e) => setOwner(e.target.value)}
            className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          />

          <input
            type="datetime-local"
            value={expiryDate}
            onChange={(e) => setExpiryDate(e.target.value)}
            className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          />

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition"
          >
            {loading ? "Shortening..." : "Shorten URL"}
          </button>
        </form>

        {error && <p className="text-red-500 mt-4">{error}</p>}

        {responseData && (
          <div className="mt-6 p-4 bg-green-100 rounded-lg space-y-2">
            <p className="font-medium text-green-700">Short URL:</p>
            <a
              href={responseData.shortUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-600 underline break-all"
            >
              {responseData.shortUrl}
            </a>

            <div className="mt-4 text-sm text-gray-700 space-y-1">
              <p><strong>ID:</strong> {responseData.id}</p>
              <p><strong>Short Code:</strong> {responseData.shortCode}</p>
              <p><strong>Original URL:</strong> {responseData.originalUrl}</p>
              <p><strong>Owner:</strong> {responseData.owner || "N/A"}</p>
              <p><strong>Expiry Date:</strong> {responseData.expiryDate || "No expiry"}</p>
              <p><strong>Click Count:</strong> {responseData.clickCount}</p>
              <p><strong>Created At:</strong> {responseData.createdAt}</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default Shortener;
