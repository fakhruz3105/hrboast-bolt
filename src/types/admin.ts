export type MenuItem = {
  icon: React.ElementType;
  label: string;
  path: string;
  submenu?: MenuItem[];
};