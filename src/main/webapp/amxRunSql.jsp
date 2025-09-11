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
  <title>SpecificationDocumentUpload</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      background: #fff;
      color: #333;
    }

    .container {
      display: flex;
      height: calc(100vh - 56px);
      font-size: 13px;
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
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 20px;
      box-sizing: border-box;
      padding-left: 50px; 
      padding-right: 50px; 
      max-width: 100%; 
      margin: 0 auto; 
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
  width: auto;       
  background-color: #5c8bff;
  color: white;
  border: none;
  border-radius: 8px;  
  cursor: pointer;
}

.input-field button:hover {
  background-color: #3f70ff;
}


    .input-field button:hover {
      background-color: #3f70ff;
    }

    .text-area-container {
      display: flex;
      flex-direction: column;
      width: 100%;
      flex-grow: 1;
    }

    .text-area-container textarea {
      width: 100%;  
      height: 100%; 
      padding: 10px;
      font-size: 14px;
      border: 1px solid #ccc;
      border-radius: 4px;
      resize: none; 
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
      <h1>Run AmxSQL</h1>

      <div class="input-field">
        <input type="text" id="inputField" placeholder="Enter the query...">
        <button id="submitBtn">Run</button>
      </div>
      <div class="text-area-container">
        <textarea id="textArea" placeholder="query result.... "></textarea>
      </div>
    </div>
  </div>
    <script>
    var loggedInUserAccess = '<%= userAccess.trim() %>';

    $(document).ready(function() {
    	  function runQuery(query) {
    	    $.ajax({
    	      url: 'http://localhost:8080/andromeda/api/datafetchservice/executequery', 
    	      type: 'GET',
    	      data: { sql: query }, 
    	      success: function(response) {
    	        if (response && response.trim() !== "") {
    	          $('#textArea').val(response);
    	        } else {
    	          $('#textArea').val("No data found for the given query.");
    	        }
    	        $('#inputField').val('');
    	      },
    	      error: function(xhr, status, error) {
    	        var errorMessage = "Error executing query.";
    	        if (xhr.responseJSON && xhr.responseJSON.error) {
    	          errorMessage = "Error: " + xhr.responseJSON.error;
    	        }
    	        $('#textArea').val(errorMessage);
    	        setTimeout(function() {
    	            $('#textArea').val('');
    	          }, 5000);
    	      }
    	    });
    	  }

    	  $('#submitBtn').click(function() {
    	    var query = $('#inputField').val().trim();
    	    if (query) {
    	      runQuery(query);
    	    } else {
    	      alert("Please enter a query.");
    	    }
    	  });

    	  $('#inputField').keypress(function(event) {
    	    if (event.which === 13) { 
    	      var query = $('#inputField').val().trim();
    	      if (query) {
    	        runQuery(query);
    	      } else {
    	        alert("Please enter a query.");
    	      }
    	    }
    	  });
    	});
  </script>
</body>
</html>
