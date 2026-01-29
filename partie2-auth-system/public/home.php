<?php
require_once 'init.php';

if (!Auth::check()) {
    header('Location: login.php');
    exit;
}

$user = Auth::user();
$users = (new User())->getAllUsers();
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - Systeme d'Authentification</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }
        .header { background: #343a40; color: white; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; }
        .content { padding: 20px; }
        .welcome { background: #fff; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .users-table { background: #fff; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #f8f9fa; }
        .btn { padding: 8px 15px; background: #dc3545; color: white; text-decoration: none; border-radius: 5px; }
        .btn:hover { background: #c82333; }
        .admin-badge { background: #28a745; color: white; padding: 3px 8px; border-radius: 3px; font-size: 12px; }
        .user-badge { background: #007bff; color: white; padding: 3px 8px; border-radius: 3px; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Systeme d'Authentification</h1>
        <div>
            <span>Connecte en tant que <?php echo htmlspecialchars($user->username); ?> 
                (<?php echo htmlspecialchars($user->role); ?>)</span>
            <a href="logout.php" class="btn" style="margin-left: 15px;">Deconnexion</a>
        </div>
    </div>
    
    <div class="content">
        <div class="welcome">
            <h2>Bienvenue, <?php echo htmlspecialchars($user->username); ?> !</h2>
            <p>Vous etes connecte avec succes au systeme d'authentification.</p>
            <p>Email : <?php echo htmlspecialchars($user->email); ?></p>
            <p>Compte cree le : <?php echo date('d/m/Y H:i', strtotime($user->created_at)); ?></p>
        </div>
        
        <?php if (Auth::isAdmin()): ?>
        <div class="users-table">
            <h2>Liste des utilisateurs</h2>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nom d'utilisateur</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Date de creation</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($users as $u): ?>
                    <tr>
                        <td><?php echo $u->id; ?></td>
                        <td><?php echo htmlspecialchars($u->username); ?></td>
                        <td><?php echo htmlspecialchars($u->email); ?></td>
                        <td>
                            <span class="<?php echo $u->role; ?>-badge">
                                <?php echo htmlspecialchars($u->role); ?>
                            </span>
                        </td>
                        <td><?php echo date('d/m/Y H:i', strtotime($u->created_at)); ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php endif; ?>
    </div>
</body>
</html>
