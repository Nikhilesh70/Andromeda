<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String partName = request.getParameter("partName") != null ? request.getParameter("partName") : "";
    String assignee = request.getParameter("assignee") != null ? request.getParameter("assignee") : "";
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>AssigneeApproval</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <style>
    .blue-toolbar {
      background-color: #0072CE;
      color: white;
      padding: 0.25rem 1rem;
      min-height: 50px;
    }
    .gray-toolbar {
      background-color: #f1f1f1;
      padding: 0.25rem 1rem;
      min-height: 40px;
      border-bottom: 1px solid #ccc;
    }
    .navbar-brand img {
      border-radius: 60px;
      width: 40px;
      height: 40px;
    }
    .form-section {
      padding: 2rem;
    }
    #responseMessage {
      margin-top: 15px;
      display: none;
    }
    #loadingSpinner {
      font-size: 14px;
      color: #555;
      display: none;
    }
  </style>
</head>
<body>

<!-- Main Toolbar -->
<nav class="navbar navbar-expand-lg blue-toolbar position-relative">
  <div class="container-fluid">
    <div class="navbar-brand d-flex align-items-center text-white">
      <img src="rr.png" alt="Logo" />
      <b class="ms-2">ANDROMEDA</b>
    </div>
  </div>
</nav>

<!-- Second Toolbar -->
<div class="gray-toolbar">
  <h6 class="m-0">Approval Panel</h6>
</div>

<!-- Form -->
<div class="form-section">
  <form id="approvalForm">
    <div class="mb-3">
      <label class="form-label"><b>Part Name:</b></label>
      <input type="text" class="form-control" name="partName" value="<%= partName %>" readonly />
    </div>

    <div class="mb-3">
      <label class="form-label"><b>Task Assignee:</b></label>
      <input type="text" class="form-control" name="assignee" value="<%= assignee %>" readonly />
    </div>

   <div class="mb-3">
  <label class="form-label"><b>Approval State:</b></label><br>
  <div class="form-check form-check-inline">
    <input class="form-check-input" type="radio" name="approvalState" id="completed" value="Completed" required />
    <label class="form-check-label" for="completed">Approve</label>
  </div>
  <div class="form-check form-check-inline">
    <input class="form-check-input" type="radio" name="approvalState" id="cancel" value="Cancelled" />
    <label class="form-check-label" for="cancel">Cancel</label>
  </div>
</div>
    <button type="submit" class="btn btn-primary">OK</button>
    <button type="reset" class="btn btn-secondary">Cancel</button>

    <!-- Spinner and response message -->
    <div id="loadingSpinner">Submitting approval...</div>
    <div id="responseMessage" class="alert" role="alert"></div>
  </form>
</div>

<!-- AJAX Logic -->
<script>
  $(document).ready(function () {
  $('#approvalForm').on('submit', function (e) {
  e.preventDefault();

const partName = $('input[name="partName"]').val();
const assignee = $('input[name="assignee"]').val();
const approvalState = $('input[name="approvalState"]:checked').val();

 if (!approvalState) {
     showMessage('Please select an approval state.', 'alert-warning');
      return;
   }
   $('#loadingSpinner').show();
   $('#responseMessage').hide();
    $.ajax({
     url: 'http://localhost:8080/andromeda/api/datafetchservice/promoteapprovalstate',
     method: 'POST',
     data: {
     partName: partName,
     assignee: assignee,
     approvalState: approvalState
 },
     success: function (response) {
     let message = "Response received.";
     let type = "alert-info";
     try {
      if (typeof response === 'string') {
          response = JSON.parse(response);
       }
       if (response.status === "success") {
       message = response.message || "Approval updated successfully.";
       type = "alert-success";
  } else if (response.error) {
  message = response.error;
 type = "alert-danger";
} else {
message = "Unknown response: " + JSON.stringify(response);
type = "alert-secondary";
}
} catch (err) {
 message = "Failed to parse server response.";
    type = "alert-danger";
    }

  showMessage(message, type);
 },
 error: function () {
	  showMessage("Approval Failed", 'alert-danger');
	},
  complete: function () {
 $('#loadingSpinner').hide();
       }
     });
  });
        	  
function showMessage(msg, type) {    	   
	$('#responseMessage')        	      
.removeClass()
.addClass('alert ' + type).html(msg).fadeIn();
   }
 });

</script>
</body>
</html>
