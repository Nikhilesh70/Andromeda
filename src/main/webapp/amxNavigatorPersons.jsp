<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>AMX Navigator Persons</title>

  <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" />
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 20px;
      background-color: white;
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
    }
    table.dataTable a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <h1>Persons List</h1>
  <div class="container">
    <table id="personsTable" class="display" style="width:100%">
      <thead>
        <tr>
          <th>Username</th>
          <th>Firstname</th>
          <th>Lastname</th>
          <th>Country</th>
          <th>Email</th>
          <th>Access</th>
        </tr>
      </thead>
      <tbody></tbody>
    </table>
    <div class="error" id="errorMessage"></div>
  </div>

  <script>
    $(document).ready(function () {
      $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/persons',
        method: 'GET',
        dataType: 'json',
        success: function (data) {
          if (!Array.isArray(data) || data.length === 0) {
            $('#errorMessage').text('No persons data found.');
            return;
          }

          $('#personsTable').DataTable({
    		data: data,
    		columns: [
        {
            data: 'Username',
            render: function (data, type, row) {
                return '<a href="PersonProperties.jsp?name=' + encodeURIComponent(row.ObjectId) + '" class="part-link">' + data + '</a>';
            }
        },
        { data: 'Firstname' },
        { data: 'Lastname' },
        { data: 'Country' },
        { data: 'Email' },
        { data: 'Access' }
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
          console.error('Error fetching persons:', error);
          $('#errorMessage').text('Failed to fetch persons data.');
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
            window.location.href = url;
          }
        } else {
          window.location.href = url; 
        }
      });
    });
  </script>
</body>
</html>
