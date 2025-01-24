import { StaffLevel } from '../types/staffLevel';

export const defaultStaffLevels: StaffLevel[] = [
  { 
    id: '1',
    name: 'Director',
    description: 'Company leadership and strategic direction',
    rank: 1
  },
  {
    id: '2',
    name: 'C-Suite',
    description: 'Executive management and decision making',
    rank: 2
  },
  {
    id: '3',
    name: 'HOD/Manager',
    description: 'Departmental management and team leadership',
    rank: 3
  },
  {
    id: '4',
    name: 'HR',
    description: 'Human resources management and administration',
    rank: 4
  },
  {
    id: '5',
    name: 'Staff',
    description: 'Regular full-time employees',
    rank: 5
  },
  {
    id: '6',
    name: 'Practical',
    description: 'Interns and temporary staff',
    rank: 6
  }
];