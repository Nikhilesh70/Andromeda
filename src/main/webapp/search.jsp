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
  <title>SearchPagePopup</title>
  <link href="https://cdn.datatables.net/select/1.3.3/css/select.dataTables.min.css" rel="stylesheet" />
  <link href="https://cdn.datatables.net/1.12.1/css/jquery.dataTables.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" crossorigin="anonymous" />
  <style>
    .blue-toolbar {
      background-color: #0072CE;
      color: white;
      padding: 0.25rem 1rem;
      min-height: 50px;
    }
    .navbar-brand {
      color: white;
      font-size: 1.1rem;
    }
    .navbar-brand img {
      border-radius: 60px;
      width: 40px;
      height: 40px;
      color: white;
    }
    .search-wrapper {
      position: absolute;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
      width: 25%;
      max-width: 100%;
    }
    .noResults {
      display: none; /* Hide initially */
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      padding: 20px;
      background-color: rgba(255, 255, 255, 0.8);
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      width: 80%; 
      max-width: 600px;
      z-index: 9999;
    }

    .inline-bullets {
      list-style-type: none;
      padding: 0;
    }

    .inline-bullets li {
      margin-bottom: 8px;
    }

    table {
      width: 100%;
      table-layout: auto;
      text-wrap-mode: nowrap;
    }

    #example {
      max-width: 100%;
      overflow-x: auto;
      margin-top: 20px;
    }

    @media (min-width: 768px) {
      .noResults {
        width: 60%;
      }
    }

    @media (max-width: 768px) {
      .noResults {
        width: 90%;
      }
    }
  </style>
</head>

<body>
  <nav class="navbar navbar-expand-lg blue-toolbar position-relative">
    <div class="container-fluid">
      <div class="navbar-brand d-flex align-items-center">
        <img src="rr.png" alt="Logo" />
        <b class="ms-2">ANDROMEDA</b>
      </div>

      <div class="search-wrapper">
        <form id="searchForm">
          <div class="input-group">
            <input type="text" id="searchInput" class="form-control" placeholder="Search..." required>
          </div>
          <button type="submit" id="searchButton" style="display: none;">Search</button>
        </form>
      </div>
    </div>
  </nav>

  <!-- Loading spinner -->
  <div id="spinnerOverlay" class="loadingSpinner" style="display:none;"></div>
  <div id="loadingText" style="display:none; position: fixed; top: 60%; left: 50%; transform: translateX(-50%); color: #0072CE; font-weight: 600;">
    Loading...
  </div>

  <!-- Results table -->
  <table id="example" class="table table-striped" style="width:100%; display:none; margin-top: 20px;">
    <thead>
      <tr id="tableHeaderRow"></tr>
    </thead>
    <tbody id="resultsBody"></tbody>
  </table>

  <!-- No Results message -->
  <div id="noResults" class="noResults">
    <h2 style="font-weight: bold; font-size:32px;">No Result Found</h2>
    <h4>Suggestions:</h4>
    <ul class="inline-bullets">
        <li>Make sure all words are spelled correctly</li>
        <li>Try different keywords.</li>
        <li>Try more general keywords.</li>
    </ul>
  </div>
  <div class="d-flex justify-content-end gap-2" style="position: fixed; bottom: 20px; right: 20px;">
    <button id="cancelBtn" class="btn btn-secondary">Cancel</button>
    <button id="okBtn" class="btn btn-primary">OK</button>
  </div>
  <div id="errorMessage" style="display:none; margin-top: 20px; color: red;"></div>

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.12.1/js/jquery.dataTables.min.js"></script>
  <script src="https://cdn.datatables.net/select/1.3.3/js/dataTables.select.min.js"></script>

  <script>
    $(document).ready(function () {
      const $errorMessage = $('#errorMessage');
      const $resultsTable = $('#example');
      const $resultsBody = $('#resultsBody');
      const $tableHeaderRow = $('#tableHeaderRow');
      const $noResultsDiv = $('#noResults');
      let dataTableInstance = null;

      function showLoading(show) {
        const spinnerOverlay = $('#spinnerOverlay');
        const loadingText = $('#loadingText');
        if (show) {
          spinnerOverlay.css('display', 'flex');
          loadingText.show();
        } else {
          spinnerOverlay.hide();
          loadingText.hide();
        }
      }

      function showError(msg) {
        $errorMessage.text(msg).show();
        showLoading(false);
        $resultsTable.hide();
      }

      $('#searchForm').on('submit', function (e) {
        e.preventDefault();
        const query = $('#searchInput').val().trim();

        if (!query) {
          showError("Please enter a search value.");
          return;
        }
        $errorMessage.hide();
        $noResultsDiv.hide();  
        $resultsTable.hide();

        showLoading(true);
        $.ajax({
        	  url: 'http://localhost:8080/andromeda/api/searchdata/popupsearch',
        	  method: 'GET',
        	  data: { name: query },
        	  dataType: 'json',
        	  success: function (data) {
        	    $('#searchInput').val('');  

        	    if (data.Status === "Success" && Array.isArray(data.Results)) {
        	      if (data.Results.length > 0) {
        	    	  renderResults(data.Results, query);
        	      } else {
        	        renderNoResults();  
        	      }
        	    } else {
        	      showError(data.Message || "Unknown server error");
        	    }
        	  },
        	  error: function (xhr) {
        	    $('#searchInput').val('');  

        	    let msg = "Failed to fetch results.";
        	    if (xhr.responseJSON && xhr.responseJSON.Message) {
        	      msg = xhr.responseJSON.Message;
        	    }
        	    showError(msg);
        	  },
        	  complete: function () {
        	    showLoading(false);
        	  }
        	});
      });

      function renderResults(results, searchQuery) {
    	  $resultsTable.show();
    	  $noResultsDiv.hide();
    	  $errorMessage.hide();
    	  $('#searchInput').val('');

    	  if (dataTableInstance) {
    	    dataTableInstance.destroy();
    	    dataTableInstance = null;
    	  }

    	  $tableHeaderRow.empty();
    	  $resultsBody.empty();

    	  searchQuery = searchQuery.toLowerCase();

    	  let columnsToShow = [];

    	  if (searchQuery === 'pasp') {
    	    columnsToShow = ["name", "supertype", "type", "description", "createdtime", "owner", "email"];
    	  } else {
    	    const type = results[0].type;

    	    const isApnAvailable = results.some(result => result.hasOwnProperty('apn'));

    	    if (type === 'fastener') {
    	      if (isApnAvailable) {
    	        columnsToShow = ["name", "apn", "supertype", "type", "description", "createddate", "owner", "email", "fastenersubpart", "variant"];
    	      } else {
    	        columnsToShow = ["name", "supertype", "type", "description", "createddate", "owner", "email", "fastenersubpart", "variant"];
    	      }
    	    } else if (type === 'partcontrol') {
    	      columnsToShow = ["name", "supertype", "type", "description", "createddate", "owner", "email", "assignee"];
    	    } else {
    	      if (isApnAvailable) {
    	        columnsToShow = ["name", "apn", "supertype", "type", "description", "createddate", "owner", "email"];
    	      } else {
    	        columnsToShow = ["name", "supertype", "type", "description", "createddate", "owner", "email"];
    	      }
    	    }
    	  }

    	  const dtColumns = [
    	    { data: null, defaultContent: '', className: 'select-checkbox', orderable: false }
    	  ].concat(columnsToShow.map(key => ({
    	    data: key,
    	    title: key.charAt(0).toUpperCase() + key.slice(1)
    	  })));

    	  dataTableInstance = new DataTable('#example', {
    	    data: results, 
    	    columns: dtColumns,
    	    columnDefs: [{
    	      orderable: false,
    	      className: 'select-checkbox',
    	      targets: 0
    	    }],
    	    select: {
    	      style: 'multi',
    	      selector: 'td:first-child'
    	    },
    	    order: [[1, 'asc']],
    	    paging: false,
    	    info: false,
    	    lengthChange: false,
    	    ordering: true
    	  });

    	  $tableHeaderRow.append('<th><input type="checkbox" id="selectAll" /></th>');
    	  columnsToShow.forEach(key => {
    	    $tableHeaderRow.append(`<th>${key.charAt(0).toUpperCase() + key.slice(1)}</th>`);
    	  });

    	  $('#selectAll').off('change').on('change', function () {
    	    if (this.checked) {
    	      dataTableInstance.rows().select();
    	    } else {
    	      dataTableInstance.rows().deselect();
    	    }
    	  });

    	  dataTableInstance.on('select deselect', function () {
    	    const allRows = dataTableInstance.rows().count();
    	    const selectedRows = dataTableInstance.rows({ selected: true }).count();
    	    $('#selectAll').prop('checked', allRows === selectedRows && allRows > 0);
    	    $('#selectAll').prop('indeterminate', selectedRows > 0 && selectedRows < allRows);
    	  });
    	}
      
      function renderNoResults() {
        if (dataTableInstance) {
          dataTableInstance.destroy();
          dataTableInstance = null;
        }
        $resultsTable.hide();
        $noResultsDiv.show();
        $errorMessage.hide();
        $resultsBody.empty();
        $tableHeaderRow.empty();
      }

      $('#cancelBtn').on('click', function() {
          window.close();  
      });

      $('#okBtn').on('click', function () {
    	  const selectedRows = [];

    	  dataTableInstance.rows({ selected: true }).every(function () {
    	    const rowData = this.data();  
    	    selectedRows.push(rowData);
    	  });

    	  console.log('Selected Rows Count:', selectedRows.length);
    	  console.log('Selected Rows:', selectedRows);

    	  if (selectedRows.length === 0) {
    	    alert('No rows selected.');
    	    return;
    	  }

    	  const sourceObjectId = new URLSearchParams(window.location.search).get('name');
    	  if (!sourceObjectId) {
    	    alert('Object ID is missing.');
    	    return;
    	  }

    	  const requestData = selectedRows;

    	  console.log('Request Data:', requestData);

    	  $.ajax({
    	    url: 'http://localhost:8080/andromeda/api/searchdata/popupsearch/' + sourceObjectId,
    	    method: 'POST',
    	    contentType: 'application/json',
    	    data: JSON.stringify(requestData),
    	    success: function (response) {
    	      if (response.connectionid) {
    	        alert('Connection Created Successfully with ID: ' + response.connectionid);
    	        if (window.opener && !window.opener.closed) {
    	          window.opener.postMessage({ action: 'closeAndRefresh' }, "*");
    	          window.close();
    	        }
    	      } else {
    	        alert('Failed to create connection.');
    	      }
    	    },
    	    error: function (xhr, status, error) {
    	      var msg = 'Error creating connection: ';
    	      if (xhr.responseJSON && xhr.responseJSON.error) {
    	        msg += xhr.responseJSON.error;
    	      } else {
    	        msg += error;
    	      }
    	      alert(msg);
    	    }
    	  });
    	});
    });
  </script>
</body>
</html>
