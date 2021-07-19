ALTER TABLE cuenta -- Tabla a la cual se asigna la llave foránea
ADD CONSTRAINT cuenta_fkey -- Nombre de la llave foránea
FOREIGN KEY (nombre_sucursal) -- Atributo o argumento de la llave foránea
REFERENCES sucursal (nombre_sucursal) -- Tabla y atributo de donde proviene la llave foránea


ALTER TABLE "03-Foodie_Fi".subscriptions
    ADD FOREIGN KEY (plan_id)
    REFERENCES "03-Foodie_Fi".plans (plan_id)
    NOT VALID;