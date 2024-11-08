import unittest
from unittest.mock import patch, MagicMock
import json
from main import main

class TestGitHubDispatch(unittest.TestCase):

    @patch('main.urllib3.PoolManager')
    @patch.dict('os.environ', {
        "GITHUB_TOKEN": "fake_github_token",
        "GITHUB_REPO_NAME": "user/fake-repo",
        "GITHUB_WORKFLOW": "trigger_workflow"
    })
    def test_main(self, mock_pool_manager):
        # Set up mock for the urllib3.PoolManager().request()
        mock_http = MagicMock()
        mock_response = MagicMock()
        mock_response.status = 204  # Simulating successful response
        mock_response.data.decode.return_value = json.dumps({"message": "Workflow triggered"})
        mock_http.request.return_value = mock_response
        mock_pool_manager.return_value = mock_http

        # Call the main function
        result: dict = main()

        # Verify the expected values
        expected_url = "https://api.github.com/repos/user/fake-repo/dispatches"
        expected_headers = {
            'Authorization': 'token fake_github_token',
            'Accept': 'application/vnd.github.v3+json'
        }
        expected_payload = {
            "event_type": "trigger_workflow"
        }

        # Assertions to verify the correct request was made
        mock_http.request.assert_called_once_with(
            'POST',
            expected_url,
            body=json.dumps(expected_payload),
            headers=expected_headers
        )

        # Verify the result of main() matches what we mocked in the response
        self.assertEqual(result["statusCode"], 204)
        self.assertEqual(result["body"], json.dumps({"message": "Workflow triggered"}))

if __name__ == '__main__':
    unittest.main()
