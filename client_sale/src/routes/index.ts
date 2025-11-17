import { Router } from "express";
import { SaleRoutes } from "./Sale.Routes";
import { ClientRoutes } from "./Client.Routes";

import { UserRoutes } from "./authorization/user";
import { RoleRoutes } from "./authorization/role";
import { RoleUserRoutes } from "./authorization/role_user";
import { RefreshTokenRoutes } from "./authorization/refresh_token";
import { ResourceRoutes } from "./authorization/resource";
import { ResourceRoleRoutes } from "./authorization/resourceRole";
import { AuthRoutes } from "./authorization/auth";

export class Routes {
    public saleRoutes: SaleRoutes = new SaleRoutes();
    public clientRoutes: ClientRoutes = new ClientRoutes();

    // --- Authorization Routes ---
    public userRoutes: UserRoutes = new UserRoutes();
    public roleRoutes: RoleRoutes = new RoleRoutes();
    public roleUserRoutes: RoleUserRoutes = new RoleUserRoutes();
    public refreshTokenRoutes: RefreshTokenRoutes = new RefreshTokenRoutes();
    public resourceRoutes: ResourceRoutes = new ResourceRoutes();
    public resourceRoleRoutes: ResourceRoleRoutes = new ResourceRoleRoutes();
    public authRoutes: AuthRoutes = new AuthRoutes();
}

