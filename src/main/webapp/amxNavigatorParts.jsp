<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Andromeda Parts</title>

  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background-color: white;
      text-wrap-mode:nowrap;
    }

    h1 {
      text-align: center;
      margin-bottom: 30px;
    }

    .container {
      width: 100%;
      margin: auto;
    }

    .error {
      text-align: center;
      margin-top: 20px;
      color: red;
    }

    table.dataTable a {
      color: #007bff;
      text-decoration: none;
      text-wrap-mode : nowrap;
    }

    table.dataTable a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <h1>Andromeda Parts</h1>
  <div class="container">
    <table id="partsTable" class="display" style="width:100%">
      <thead>
        <tr>
          <th>Name</th>
          <th>APN</th>
          <th>SuperType</th>
          <th>Type</th>
          <th>Description</th>
          <th>CreatedDate</th>
          <th>Owner</th>
          <th>Email</th> 
        </tr>
      </thead>
      <tbody></tbody>
    </table>
    <div class="error" id="errorMessage"></div>
  </div>

  <script>
    $(document).ready(function () {
      $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/latestparts',
        method: 'GET',
        dataType: 'json',
        success: function (data) {
          if (!Array.isArray(data) || data.length === 0) {
            $('#errorMessage').text('No parts data found.');
            return;
          }

          $('#partsTable').DataTable({
        	  data: data,
        	  columns: [
        	    {
        	      data: 'name',
        	      render: function (data, type, row) {
        	        return '<a href="Properties.jsp?name=' + encodeURIComponent(row.objectid) + '" class="part-link">' + data + '</a>';
        	      }
        	    },
        	    { data: 'apn' },
        	    { data: 'supertype' },
        	    { data: 'type' },
        	    { data: 'description' },
        	    {
        	      data: 'createddate',
        	      render: function (data) {
        	        if (!data) return '';
        	        const date = new Date(data);
        	        if (isNaN(date.getTime())) return data;
        	        return date.toLocaleDateString();
        	      }
        	    },
        	    { data: 'owner' },
        	    { data: 'email' }
        	  ],
        	  paging: false,
        	  searching: false,
        	  info: false,
        	  ordering: true,
        	  lengthChange: false,
        	  destroy: true
        	});

        },
        error: function (xhr, status, error) {
          console.error('Error fetching parts:', error);
          $('#errorMessage').text('Failed to fetch parts data.');
        }
      });

      $(document).on('click', 'a.part-link', function (e) {
        e.preventDefault();
        const url = $(this).attr('href');
        if (window.parent && window.parent.document) {
          const iframe = window.parent.document.querySelector('iframe[name="contentFrame"]');
          if (iframe) {
            iframe.src = url;
          } else {
            console.warn('Iframe not found in parent window.');
          }
        }
      });
    });
  </script>
</body>
</html>
