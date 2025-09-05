<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Part Control List</title>
  
  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background-color: white;
      text-wrap-mode: nowrap;
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
      white-space: nowrap;
      text-wrap-mode:nowrap;
    }

    table.dataTable a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <h1>Part Control List</h1>
  <div class="container">
    <table id="partsTable" class="display" style="width:100%">
      <thead><tr></tr></thead>
      <tbody></tbody>
    </table>
    <div class="error" id="errorMessage"></div>
  </div>

  <script>
    $(document).ready(function () {
      $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/getallpartcontrol',
        method: 'GET',
        dataType: 'json',
        success: function (response) {
          if (!Array.isArray(response) || response.length === 0) {
            $('#errorMessage').text('No part control data found.');
            return;
          }

          const dataArray = response; 
          const desiredColumns = ["name", "supertype", "type", "description", "createddate", "owner", "email", "assignee"];

          const $theadTr = $('#partsTable thead tr');
          $theadTr.empty();

          const columns = [];
          desiredColumns.forEach(function (key) {
            $theadTr.append('<th>' + key.charAt(0).toUpperCase() + key.slice(1) + '</th>');

            if (key === 'name') {
              columns.push({
                data: 'name',
                render: function (data, type, row) {
                  if (!data) return '';
                  return '<a href="Partcontroldetails.jsp?name=' + encodeURIComponent(row.objectid) + '" class="part-link">' + data + '</a>';
                }
              });
            } else if (key === 'createddate') {
              columns.push({
                data: 'createddate',
                render: function (data) {
                  const date = new Date(data);
                  if (!isNaN(date.getTime())) {
                    return date.toLocaleString(); 
                  }
                  return data || '';
                }
              });
            } else {
              columns.push({
                data: key,
                render: function (data) {
                  return data || 'N/A'; 
                }
              });
            }
          });

          $('#partsTable').DataTable({
            data: dataArray,
            columns: columns,
            paging: false,
            searching: false,
            info: false,
            ordering: true,
            lengthChange: false,
            destroy: true
          });
        },
        error: function (xhr, status, error) {
          console.error('Error fetching part control data:', error);
          $('#errorMessage').text('Failed to fetch part control data.');
        }
      });
    });
  </script>
</body>
</html>
