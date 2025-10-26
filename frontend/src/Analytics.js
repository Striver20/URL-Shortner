import { useState } from "react";
import axios from "axios";

function Analytics() {
  const [shortCode, setShortCode] = useState("");
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setAnalytics(null);

    try {
      const response = await axios.get(
        `http://54.227.34.20:8080/api/v1/urls/${shortCode}/analytics`
      );
      console.log(response);
      if (response.data.error) {
        const errMsg = response.data.error;
        console.log(errMsg);
        if (errMsg.includes("expired")) {
          window.location.href = "http://54.227.34.20:8080/expired";
          return;
        }

        // other error — show message
        setError(errMsg);
        return;
      }

      setAnalytics(response.data);
    } catch (err) {
      if (err.response && err.response.data) {
        const errMsg =
          err.response.data.error ||
          err.response.data.message ||
          "Error occurred";

        if (errMsg.includes("expired")) {
          window.location.href = "http://54.227.34.20:8080/expired";
          return;
        }

        setError(errMsg);
      } else if (err.request) {
        setError("No response from server");
      } else {
        setError(err.message);
      }
    } finally {
      setLoading(false);
    }
  };

  function formatDateTime(dateStr) {
    if (!dateStr) return "N/A";
    const date = new Date(dateStr);
    return date.toLocaleString("en-IN", {
      weekday: "short",
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="bg-white shadow-xl rounded-2xl p-8 w-full max-w-lg">
        <h1 className="text-2xl font-bold text-center mb-6">Analytics</h1>

        <form onSubmit={handleSubmit} className="space-y-4">
          <input
            type="text"
            placeholder="Enter short code (e.g., b)"
            value={shortCode}
            onChange={(e) => setShortCode(e.target.value)}
            required
            className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          />

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-green-600 text-white py-2 rounded-lg hover:bg-green-700 transition"
          >
            {loading ? "Fetching..." : "Get Analytics"}
          </button>
        </form>

        {error && <p className="text-red-500 mt-4">{error}</p>}

        {analytics && (
          <div className="mt-6 p-4 bg-blue-100 rounded-lg space-y-2 text-sm text-gray-800">
            <p>
              <strong>Short Code:</strong> {analytics.shortCode}
            </p>

            <p>
              <strong>Short URL:</strong>{" "}
              {analytics.shortUrl ? (
                <a
                  href={analytics.shortUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-600 underline break-all"
                >
                  {analytics.shortUrl}
                </a>
              ) : (
                <span className="text-gray-500">Not generated</span>
              )}
            </p>

            <p>
              <strong>Original URL:</strong> {analytics.originalUrl}
            </p>
            <p>
              <strong>Click Count:</strong> {analytics.clickCount}
            </p>
            <p>
              <strong>Last Accessed At:</strong>{" "}
              {formatDateTime(analytics.lastAccessedAt)}
            </p>
            <p>
              <strong>Created At:</strong> {formatDateTime(analytics.createdAt)}
            </p>
            <p>
              <strong>Expiry Date:</strong>{" "}
              {formatDateTime(analytics.expiryDate)}
            </p>
            <p>
              <strong>Owner:</strong> {analytics.owner || "N/A"}
            </p>

            {/* Detailed Click Information */}
            {analytics.clickDetails && analytics.clickDetails.length > 0 && (
              <div className="mt-4 pt-4 border-t border-blue-200">
                <h3 className="font-bold text-base mb-3 text-gray-800">
                  Click Details ({analytics.clickDetails.length} clicks):
                </h3>
                <div className="space-y-3 max-h-60 overflow-y-auto">
                  {analytics.clickDetails.map((click, index) => (
                    <div
                      key={index}
                      className="bg-white p-3 rounded border text-xs"
                    >
                      <p className="font-semibold text-gray-700 mb-2">
                        Click #{index + 1}:
                      </p>
                      <div className="space-y-1">
                        <p>
                          <strong>Time:</strong>{" "}
                          {formatDateTime(click.clickedAt)}
                        </p>
                        <p>
                          <strong>IP Address:</strong> {click.ipAddress}
                        </p>
                        <p>
                          <strong>User Agent:</strong>{" "}
                          {click.userAgent ? (
                            <span title={click.userAgent}>
                              {click.userAgent.length > 50
                                ? click.userAgent.substring(0, 50) + "..."
                                : click.userAgent}
                            </span>
                          ) : (
                            "Unknown"
                          )}
                        </p>
                        <p>
                          <strong>Referrer:</strong>{" "}
                          {click.referrer ? (
                            <span className="text-blue-600 break-all">
                              {click.referrer}
                            </span>
                          ) : (
                            <span className="text-gray-500">Direct</span>
                          )}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

export default Analytics;
