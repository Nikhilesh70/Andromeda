<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userAccess = (String) session.getAttribute("userAccess");
    if (userAccess == null) {
        userAccess = "Admin";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>AmxRunSQL</title>
  <style>
  html, body {
    height: 100%;
    margin: 0;
    padding: 0;
  }

  body {
    font-family: Arial, sans-serif;
    background: #fff;
    color: #333;
    overflow: hidden;
  }

  .container {
    display: flex;
    height: 100%;
    font-size: 13px;
    position: relative;
  }

  .sidebar {
    width: 16%;
    background-color: #f8f9fa;
    border-right: 1px solid #ddd;
    padding: 20px;
    box-sizing: border-box;
  }

  .main-panel {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    padding: 20px 50px;
    box-sizing: border-box;
    overflow: hidden;
  }

  h1 {
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
  }

  .input-field {
    display: flex;
    gap: 10px;
    width: 100%;
    align-items: center;
  }

  .input-field input {
    padding: 8px;
    font-size: 14px;
    width: 800px;
    height: 40px;
    border: 1px solid #ccc;
    border-radius: 4px;
  }

  .input-field button {
    padding: 12px 20px;
    font-size: 16px;
    background-color: #5c8bff;
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
  }

  .input-field button:hover {
    background-color: #3f70ff;
  }

  .text-area-container {
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    margin: 1.5px;
  }

  .text-area-container textarea {
    width: 100%;
    height: 100%;
    padding: 8px;
    font-size: 14px;
    border: 1px solid #ccc;
    border-radius: 4px;
    resize: none;
    font-family: "Sitka Subheading Semibold", sans-serif;
    box-sizing: border-box;
    flex-grow: 1;
  }

  #fileViewer {
    display: none;
    width: 30%;
    height: 100%;
    background-color: #fefefe;
    border-left: 1px solid #ddd;
    box-sizing: border-box;
    overflow-y: auto;
    position: relative;
    flex-shrink: 0;
  }

  #fileViewerContent {
    padding: 20px;
    font-family: monospace;
    font-size: 14px;
    white-space: pre-wrap;
    position: relative;
    height: 100%;
    box-sizing: border-box;
  }

  #closeMark {
    position: absolute;
    top: 10px;
    right: 10px;
    font-size: 24px;
    color: blue;
    cursor: pointer;
    font-weight: bold;
    z-index: 10;
  }

  #closeMark:hover {
    color: red;
  }

  #queriesDoc {
    color: #5c8bff;
    cursor: pointer;
    text-decoration: underline;
    user-select: none;
  }

  #queriesDoc:hover {
    color: #3f70ff;
  }

  #refreshPage {
    margin-left: 10px;
    cursor: pointer;
    color: #5c8bff;
  }

  #refreshPage:hover {
    color: #3f70ff;
  }
 .header-row {
  text-align: center;
  margin-bottom: 10px;
}

.header-row h1 {
  font-size: 24px;
  margin: 0 auto;
}


.section-label {
  font-weight: bold;
  font-size: 14px;
  margin: 10px 0 5px 0;
  color: #333;
}
  

  </style>
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
  <script>var loggedInUserAccess = '<%= userAccess.trim() %>';</script>
</head>
<body>
  <div class="container">
<div class="main-panel">
  <div class="header-row">
    <h1>Run ASQL</h1>
  </div>
  <div class="section-label">SQL Command</div>
  <div class="input-field">
    <input type="text" id="inputField" placeholder="Enter the query...">
    <button id="submitBtn">Run</button>
    <span id="queriesDoc">Help</span>
    <img id="refreshPage" src="https://img.icons8.com/?size=100&id=t7r2A42vsY6O&format=png&color=000000" alt="Refresh" title="Refresh" style="margin-left: 10px; cursor: pointer; width: 20px; height: 20px;">
  </div>
  <div class="section-label">Results</div>
  <div class="text-area-container">
    <textarea id="textArea" placeholder="Query result...." readonly oncontextmenu="return false;"></textarea>
  </div>
</div>

    <div id="fileViewer">
      <div id="fileViewerContent">
        <button id="closeMark">Close</button>
        <pre id="fileTextContent" style="white-space: pre-wrap; margin-top: 10px;"></pre>
      </div>
    </div>
  </div>
  <script>
    var loggedInUserAccess = '<%= userAccess.trim() %>';
    $(document).ready(function () {
      function runQuery(query) {
        $.ajax({
          url: 'http://localhost:8080/andromeda/api/datafetchservice/executequery',
          type: 'GET',
          data: {
            sql: query,
            _: new Date().getTime()
          },
          success: function (response) {
            let resultText;
            if (typeof response === 'object') {
              resultText = JSON.stringify(response, null, 2);
            } else if (typeof response === 'string') {
              resultText = response.trim();
            }
            if (resultText) {
              $('#textArea').val(resultText);
            } else {
              $('#textArea').val("No data found for the given query.");
            }
          },
          error: function (xhr, status, error) {
            var errorMessage = "Error executing query.";
            if (xhr.responseJSON && xhr.responseJSON.error) {
              errorMessage = "Error: " + xhr.responseJSON.error;
            }
            $('#textArea').val(errorMessage);
            setTimeout(function () {
              $('#textArea').val('');
            }, 5000);
          }
        });
      }
      $('#submitBtn').click(function () {
        var query = $('#inputField').val().trim();
        if (query) {
          runQuery(query);
        } else {
          alert("Please enter a query.");
        }
      });
      $('#inputField').keypress(function (event) {
        if (event.which === 13) {
          var query = $('#inputField').val().trim();
          if (query) {
            runQuery(query);
          } else {
            alert("Please enter a query.");
          }
        }
      });
      $('#queriesDoc').click(function () {
        $.ajax({
          url: '/andromeda/queries.txt',
          type: 'GET',
          success: function (data) {
            $('#fileTextContent').text(data);
            $('#fileViewer').show();
          },
          error: function (xhr, status, error) {
            $('#fileTextContent').text("Error loading the document.");
            $('#fileViewer').show();
          }
        });
      });
      $('#closeMark').click(function () {
        $('#fileViewer').hide();
      });
      $('#fileViewer').click(function (event) {
        if (event.target === this) {
          $(this).hide();
        }
      });
      $('#refreshPage').click(function () {
        $('#inputField').val('');
        $('#textArea').val('');
        $('#fileViewer').hide();
      });
    });
  </script>
</body>
</html>
