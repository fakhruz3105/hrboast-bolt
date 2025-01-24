import { EvaluationQuestion } from '../types/evaluation';

export type EvaluationCategory = {
  id: string;
  name: string;
  questions: EvaluationQuestion[];
};

// Default evaluation categories for staff
export const defaultEvaluationCategories: EvaluationCategory[] = [
  {
    id: 'job-knowledge',
    name: 'Job Knowledge and Skills',
    questions: [
      {
        id: 'jk-1',
        category: 'Job Knowledge',
        question: 'Understanding of role-specific responsibilities',
        description: 'Demonstrates clear understanding and execution of core job responsibilities',
        type: 'rating'
      },
      {
        id: 'jk-2',
        category: 'Job Knowledge',
        question: 'Proficiency in necessary tools and software',
        description: 'Shows competency in using required tools, software, and equipment',
        type: 'rating'
      },
      {
        id: 'jk-3',
        category: 'Job Knowledge',
        question: 'Problem-solving and expertise application',
        description: 'Effectively applies knowledge to solve problems and complete tasks',
        type: 'rating'
      }
    ]
  },
  {
    id: 'work-quality',
    name: 'Work Quality',
    questions: [
      {
        id: 'wq-1',
        category: 'Work Quality',
        question: 'Attention to detail and accuracy',
        description: 'Produces work that is accurate, thorough, and meets quality standards',
        type: 'rating'
      },
      {
        id: 'wq-2',
        category: 'Work Quality',
        question: 'Consistency in meeting expectations',
        description: 'Consistently delivers work that meets or exceeds expectations',
        type: 'rating'
      },
      {
        id: 'wq-3',
        category: 'Work Quality',
        question: 'Performance under pressure',
        description: 'Maintains quality standards even under pressure or tight deadlines',
        type: 'rating'
      }
    ]
  },
  {
    id: 'communication',
    name: 'Communication',
    questions: [
      {
        id: 'com-1',
        category: 'Communication',
        question: 'Verbal and written communication',
        description: 'Communicates clearly and professionally in both verbal and written forms',
        type: 'rating'
      },
      {
        id: 'com-2',
        category: 'Communication',
        question: 'Active listening and responsiveness',
        description: 'Demonstrates active listening and responds appropriately to others',
        type: 'rating'
      },
      {
        id: 'com-3',
        category: 'Communication',
        question: 'Team collaboration and idea sharing',
        description: 'Effectively shares ideas and collaborates with team members',
        type: 'rating'
      }
    ]
  },
  {
    id: 'productivity',
    name: 'Productivity and Efficiency',
    questions: [
      {
        id: 'prod-1',
        category: 'Productivity',
        question: 'Time management and deadlines',
        description: 'Effectively manages time and consistently meets deadlines',
        type: 'rating'
      },
      {
        id: 'prod-2',
        category: 'Productivity',
        question: 'Resource utilization',
        description: 'Uses available resources efficiently to complete tasks',
        type: 'rating'
      },
      {
        id: 'prod-3',
        category: 'Productivity',
        question: 'Workflow optimization',
        description: 'Takes initiative in optimizing workflows and managing workload',
        type: 'rating'
      }
    ]
  },
  {
    id: 'dependability',
    name: 'Dependability',
    questions: [
      {
        id: 'dep-1',
        category: 'Dependability',
        question: 'Attendance and punctuality',
        description: 'Maintains reliable attendance and arrives on time',
        type: 'rating'
      },
      {
        id: 'dep-2',
        category: 'Dependability',
        question: 'Task completion reliability',
        description: 'Consistently completes assigned tasks as expected',
        type: 'rating'
      },
      {
        id: 'dep-3',
        category: 'Dependability',
        question: 'Accountability',
        description: 'Takes responsibility for actions and outcomes',
        type: 'rating'
      }
    ]
  },
  {
    id: 'customer-service',
    name: 'Customer Service',
    questions: [
      {
        id: 'cs-1',
        category: 'Customer Service',
        question: 'Client interaction professionalism',
        description: 'Maintains professional and courteous interactions with clients',
        type: 'rating'
      },
      {
        id: 'cs-2',
        category: 'Customer Service',
        question: 'Issue resolution',
        description: 'Effectively addresses and resolves client concerns',
        type: 'rating'
      },
      {
        id: 'cs-3',
        category: 'Customer Service',
        question: 'Customer-first attitude',
        description: 'Demonstrates a strong commitment to customer satisfaction',
        type: 'rating'
      }
    ]
  },
  {
    id: 'teamwork',
    name: 'Teamwork and Collaboration',
    questions: [
      {
        id: 'team-1',
        category: 'Teamwork',
        question: 'Team contribution',
        description: 'Actively contributes to team goals and assists colleagues',
        type: 'rating'
      },
      {
        id: 'team-2',
        category: 'Teamwork',
        question: 'Conflict resolution',
        description: 'Effectively resolves conflicts and maintains positive relationships',
        type: 'rating'
      },
      {
        id: 'team-3',
        category: 'Teamwork',
        question: 'Collaborative environment',
        description: 'Promotes and supports a collaborative work environment',
        type: 'rating'
      }
    ]
  },
  {
    id: 'adaptability',
    name: 'Adaptability and Flexibility',
    questions: [
      {
        id: 'adapt-1',
        category: 'Adaptability',
        question: 'Openness to feedback',
        description: 'Receptive to feedback and demonstrates willingness to improve',
        type: 'rating'
      },
      {
        id: 'adapt-2',
        category: 'Adaptability',
        question: 'Adaptation to change',
        description: 'Effectively adapts to new tools, processes, or roles',
        type: 'rating'
      },
      {
        id: 'adapt-3',
        category: 'Adaptability',
        question: 'Problem-solving flexibility',
        description: 'Shows flexibility in handling unexpected situations',
        type: 'rating'
      }
    ]
  },
  {
    id: 'initiative',
    name: 'Initiative and Innovation',
    questions: [
      {
        id: 'init-1',
        category: 'Initiative',
        question: 'Project ownership',
        description: 'Takes ownership of projects and goes beyond basic requirements',
        type: 'rating'
      },
      {
        id: 'init-2',
        category: 'Initiative',
        question: 'Creative solutions',
        description: 'Proposes creative solutions and suggestions for improvement',
        type: 'rating'
      },
      {
        id: 'init-3',
        category: 'Initiative',
        question: 'Professional development',
        description: 'Shows proactive approach to learning and development',
        type: 'rating'
      }
    ]
  }
];

// Manager evaluation categories
export const managerEvaluationCategories: EvaluationCategory[] = [
  {
    id: 'leadership',
    name: 'Leadership Skills',
    questions: [
      {
        id: 'lead-1',
        category: 'Leadership',
        question: 'Vision and Strategy',
        description: 'Ability to set clear direction and strategic goals for the team',
        type: 'rating'
      },
      {
        id: 'lead-2',
        category: 'Leadership',
        question: 'Team Development',
        description: 'Effectiveness in developing and mentoring team members',
        type: 'rating'
      },
      {
        id: 'lead-3',
        category: 'Leadership',
        question: 'Change Management',
        description: 'Ability to lead and manage change effectively',
        type: 'rating'
      }
    ]
  },
  {
    id: 'management',
    name: 'Management Skills',
    questions: [
      {
        id: 'mgmt-1',
        category: 'Management',
        question: 'Resource Management',
        description: 'Effective allocation and utilization of team resources',
        type: 'rating'
      },
      {
        id: 'mgmt-2',
        category: 'Management',
        question: 'Performance Management',
        description: 'Setting clear expectations and managing team performance',
        type: 'rating'
      },
      {
        id: 'mgmt-3',
        category: 'Management',
        question: 'Project Management',
        description: 'Planning, execution, and delivery of team projects',
        type: 'rating'
      }
    ]
  },
  {
    id: 'communication',
    name: 'Communication and Stakeholder Management',
    questions: [
      {
        id: 'comm-1',
        category: 'Communication',
        question: 'Stakeholder Communication',
        description: 'Effectiveness in communicating with various stakeholders',
        type: 'rating'
      },
      {
        id: 'comm-2',
        category: 'Communication',
        question: 'Team Communication',
        description: 'Clear and effective communication with team members',
        type: 'rating'
      },
      {
        id: 'comm-3',
        category: 'Communication',
        question: 'Conflict Resolution',
        description: 'Ability to handle and resolve conflicts effectively',
        type: 'rating'
      }
    ]
  },
  {
    id: 'innovation',
    name: 'Innovation and Business Development',
    questions: [
      {
        id: 'innov-1',
        category: 'Innovation',
        question: 'Process Improvement',
        description: 'Initiatives to improve team processes and efficiency',
        type: 'rating'
      },
      {
        id: 'innov-2',
        category: 'Innovation',
        question: 'Business Growth',
        description: 'Contribution to business growth and development',
        type: 'rating'
      },
      {
        id: 'innov-3',
        category: 'Innovation',
        question: 'Strategic Planning',
        description: 'Development and execution of strategic initiatives',
        type: 'rating'
      }
    ]
  }
];

// Function to get evaluation categories based on staff level
export function getEvaluationCategories(level: string): EvaluationCategory[] {
  if (level === 'HOD/Manager' || level === 'C-Suite') {
    return managerEvaluationCategories;
  }
  return defaultEvaluationCategories;
}